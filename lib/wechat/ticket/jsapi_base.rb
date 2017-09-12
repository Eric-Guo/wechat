require 'digest/sha1'
require 'securerandom'

module Wechat
  module Ticket
    class JsapiBase
      attr_reader :client, :access_token, :jsapi_ticket_file, :access_ticket, :ticket_life_in_seconds, :got_ticket_at

      def initialize(client, access_token, jsapi_ticket_file)
        @client = client
        @access_token = access_token
        @jsapi_ticket_file = jsapi_ticket_file
        @random_generator = Random.new
      end

      def ticket(tries = 2)
        # Possible two worker running, one worker refresh ticket, other unaware, so must read every time
        read_ticket_from_store
        refresh if remain_life_seconds < @random_generator.rand(30..3 * 60)
        access_ticket
      rescue AccessTokenExpiredError
        access_token.refresh
        retry unless (tries -= 1).zero?
      end

      def oauth2_state
        ticket
        @oauth2_state
      end

      # Obtain the wechat jssdk config signature parameter and return below hash
      #  params = {
      #    noncestr: noncestr,
      #    timestamp: timestamp,
      #    jsapi_ticket: ticket,
      #    url: url,
      #    signature: signature
      #  }
      def signature(url)
        params = {
          noncestr: SecureRandom.base64(16),
          timestamp: Time.now.to_i,
          jsapi_ticket: ticket,
          url: url
        }
        pairs = params.keys.sort.map do |key|
          "#{key}=#{params[key]}"
        end
        result = Digest::SHA1.hexdigest pairs.join('&')
        params.merge(signature: result)
      end

      protected

      def read_ticket_from_store
        td = read_ticket
        @ticket_life_in_seconds = td.fetch('ticket_expires_in').to_i
        @got_ticket_at = td.fetch('got_ticket_at').to_i
        @oauth2_state = td.fetch('oauth2_state')
        @access_ticket = td.fetch('ticket') # return access_ticket same time
      rescue JSON::ParserError, Errno::ENOENT, KeyError, TypeError
        refresh
      end

      def write_ticket_to_store(ticket_hash)
        ticket_hash['got_ticket_at'.freeze] = Time.now.to_i
        ticket_hash['ticket_expires_in'.freeze] = ticket_hash.delete('expires_in')
        write_ticket(ticket_hash)
      end

      def read_ticket
        JSON.parse(File.read(jsapi_ticket_file))
      end

      def write_ticket(ticket_hash)
        File.write(jsapi_ticket_file, ticket_hash.to_json)
      end

      def remain_life_seconds
        ticket_life_in_seconds - (Time.now.to_i - got_ticket_at)
      end
    end
  end
end
