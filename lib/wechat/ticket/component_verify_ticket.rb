# frozen_string_literal: true

module Wechat
  module Ticket
    class ComponentVerifyTicket
      attr_reader :ticket_file, :verify_ticket, :ticket_life_in_seconds, :got_ticket_at

      def initialize(ticket_file)
        @ticket_file = ticket_file
        @random_generator = Random.new
      end

      def ticket
        # Possible two worker running, one worker refresh token, other unaware, so must read every time
        read_ticket_from_store
        return nil if verify_ticket.blank? or (remain_life_seconds < @random_generator.rand(30..3 * 60))
        verify_ticket
      end

      def update(ticket_hash)
        write_ticket_to_store(ticket_hash)
      end

      protected

      def read_ticket_from_store
        td = read_ticket
        @ticket_life_in_seconds = td.fetch('ticket_expires_in').to_i
        @got_ticket_at = td.fetch('got_ticket_at').to_i
        @verify_ticket = td.fetch('verify_ticket') # return access_token same time
      rescue JSON::ParserError, Errno::ENOENT, KeyError, TypeError
        nil
      end

      def write_ticket_to_store(ticket_hash)
        raise InvalidCredentialError unless ticket_hash.is_a?(Hash) && ticket_hash['verify_ticket']
        ticket_hash['got_ticket_at'] = Time.now.to_i
        ticket_hash['ticket_expires_in'] = 12.hours.to_i
        write_ticket(ticket_hash)
      end

      def read_ticket
        JSON.parse(File.read(ticket_file))
      end

      def write_ticket(ticket_hash)
        File.open(ticket_file, 'w') {|f| f.write(ticket_hash.to_json) }
      end

      def remain_life_seconds
        ticket_life_in_seconds - (Time.now.to_i - got_ticket_at)
      end
    end
  end
end
