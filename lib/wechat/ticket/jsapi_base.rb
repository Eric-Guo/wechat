require 'digest/sha1'

module Wechat
  module Ticket
    class JsapiBase
      attr_reader :client, :access_token, :jsapi_ticket_file, :jsapi_ticket_data

      def initialize(client, access_token, jsapi_ticket_file)
        @client = client
        @access_token = access_token
        @jsapi_ticket_file = jsapi_ticket_file
        @random_generator = Random.new
      end

      # Obtain the wechat jssdk signature's ticket and return below hash
      #  {
      #    "errcode":0,
      #    "errmsg":"ok",
      #    "ticket":"bxLdikRXVbTPdHSM05e5u5sUoXNKd8-41ZO3MhKoyN5OfkWITDGgnr2fwJ0m9E8NYzWKVZvdVtaUgWvsdshFKA",
      #    "expires_in":7200
      #  }
      def ticket
        begin
          @jsapi_ticket_data ||= JSON.parse(File.read(jsapi_ticket_file))
          created_at = jsapi_ticket_data['created_at'].to_i
          expires_in = jsapi_ticket_data['expires_in'].to_i
          if Time.now.to_i - created_at >= expires_in - @random_generator.rand(30..3 * 60)
            fail 'jsapi_ticket may be expired'
          end
        rescue
          refresh
        end
        valid_ticket(@jsapi_ticket_data)
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
        timestamp = Time.now.to_i
        noncestr = SecureRandom.base64(16)
        params = {
          noncestr: noncestr,
          timestamp: timestamp,
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

      def valid_ticket(jsapi_ticket_data)
        ticket = jsapi_ticket_data['ticket'] || jsapi_ticket_data[:ticket]
        fail "Response didn't have ticket" if ticket.blank?
        ticket
      end
    end
  end
end
