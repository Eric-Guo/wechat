# frozen_string_literal: true

require 'wechat/ticket/jsapi_base'

module Wechat
  module Ticket
    class CorpJsapiTicket < JsapiBase
      def refresh
        data = client.get('get_jsapi_ticket', params: { access_token: access_token.token })
        data['oauth2_state'] = SecureRandom.hex(16)
        write_ticket_to_store(data)
        read_ticket_from_store
      end
    end
  end
end
