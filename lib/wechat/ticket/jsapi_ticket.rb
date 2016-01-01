require 'wechat/ticket/jsapi_base'

module Wechat
  module Ticket
    class JsapiTicket < JsapiBase
      # refresh jsapi ticket
      def refresh
        data = client.get('ticket/getticket', params: { access_token: access_token.token, type: 'jsapi' })
        write_ticket_to_file(data)
        read_ticket_from_file
        jsapi_ticket_data
      end
    end
  end
end
