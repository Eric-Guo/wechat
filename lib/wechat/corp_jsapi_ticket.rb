require 'wechat/jsapi_base'

module Wechat
  class CorpJsapiTicket < JsapiBase
    # refresh jsapi ticket
    def refresh
      data = client.get('get_jsapi_ticket', params: { access_token: access_token.token })
      data.merge!('created_at'.freeze => Time.now.to_i)
      File.open(jsapi_ticket_file, 'w') { |f| f.write(data.to_json) } if valid_ticket(data)
      @jsapi_ticket_data = data
    end
  end
end
