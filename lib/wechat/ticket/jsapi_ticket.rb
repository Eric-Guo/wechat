require 'wechat/ticket/jsapi_base'

module Wechat
  module Ticket
    class JsapiTicket < JsapiBase
      # refresh jsapi ticket
      def refresh
        data = client.get('ticket/getticket', params: { access_token: access_token.token, type: 'jsapi' })
        data.merge!('created_at'.freeze => Time.now.to_i)
        File.open(jsapi_ticket_file, 'w') { |f| f.write(data.to_json) } if valid_ticket(data)
        @jsapi_ticket_data = data
      end
    end
  end
end
