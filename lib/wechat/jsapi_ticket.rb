require 'digest/sha1'

module Wechat
  class JsapiTicket
    attr_reader :client, :access_token, :jsapi_ticket_file, :jsapi_ticket_data

    def initialize(client, access_token, jsapi_ticket_file)
      @client = client
      @access_token = access_token
      @jsapi_ticket_file = jsapi_ticket_file
    end

    def ticket
      begin
        @jsapi_ticket_data ||= JSON.parse(File.read(jsapi_ticket_file))
      rescue
        self.refresh
      end
      return valid_ticket(@jsapi_ticket_data)
    end

    def refresh
      data = client.get("ticket/getticket", params: { access_token: access_token.token, type: "jsapi"})
      File.open(jsapi_ticket_file, 'w'){|f| f.write(data.to_json)} if valid_ticket(data)
      return @jsapi_ticket_data = data
    end

    def signature
      params = {
        noncestr: 'Wm3WZYTPz0wzccnW',
        timestamp: 1414587457,
        jsapi_ticket: 'sM4AOVdWfPE4DxkXGEs8VMCPGGVi4C3VM0P37wVUCFvkVAy_90u5h9nbSlYy3-Sl-HhTdfl2fzFy1AOcHKP7qg',
        url: 'http://mp.weixin.qq.com?params=value'
      }
      pairs = params.keys.sort.map do |key|
        "#{key}=#{params[key]}"
      end
      result = Digest::SHA1.hexdigest pairs.join("&")
      params.merge(signature: result)
    end

    private 
    def valid_ticket jsapi_ticket_data
      ticket = jsapi_ticket_data["ticket"]
      raise "Response didn't have ticket" if  ticket.blank?
      return ticket
    end

  end
end
