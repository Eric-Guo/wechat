require 'rest_client'
module Wechat

  class JsTicket
    attr_reader :ticket_info,:access_token,:client

    def initialize(client, access_token, ticket_file)
      @client = client
      @access_token = access_token
      @ticket_file = ticket_file
    end

    def ticket
      begin
        @ticket_info ||= JSON.parser(File.read(@ticket_file))

        if ticket_expired?
          refresh_ticket
        end
      rescue
        set_ticket
      end

      @ticket_info[:ticket]

    end

    def ticket_expired?
      @ticket_info[:expired_at] <= Time.now.to_i
    end

    def refresh_ticket
      set_ticket
    end

    def set_ticket tries = 2
      begin
        data = @client.get('ticket/getticket', params: {access_token: @access_token.token, type: 'jsapi'})
        require "json"
        @ticket_info = {:ticket => data[:ticket], :expired_at => data[:expires_in] + Time.now.to_i}
        File.open(@ticket_file, 'w') { |f| f.write(@ticket_info.to_json) }
      rescue AccessTokenExpiredError
        @access_token.refresh
        retry unless (tries -= 1).zero?
      end

    end

  end

end
