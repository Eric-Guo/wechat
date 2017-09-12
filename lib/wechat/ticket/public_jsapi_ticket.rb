require 'wechat/ticket/jsapi_base'

module Wechat
  module Ticket
    class PublicJsapiTicket < JsapiBase
      def refresh
        data = client.get('ticket/getticket', params: { access_token: access_token.token, type: 'jsapi' })
        data['oauth2_state'] = SecureRandom.hex(16)
        write_ticket_to_store(data)
        read_ticket_from_store
      end
    end
  end
end
