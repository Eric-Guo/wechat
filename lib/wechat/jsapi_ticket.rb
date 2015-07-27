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

    # 获取 jsapi_ticket 签名, 并返回所有必要参数
    def signature(url)
      timestamp = Time.now.to_i
      noncestr = generate_noncestr
      params = {
        noncestr: noncestr,
        timestamp: timestamp,
        jsapi_ticket: ticket,
        url: url
      }
      pairs = params.keys.sort.map do |key|
        "#{key}=#{params[key]}"
      end
      result = Digest::SHA1.hexdigest pairs.join("&")
      params.merge(signature: result)
    end

    private
    def valid_ticket jsapi_ticket_data
      ticket = jsapi_ticket_data["ticket"] || jsapi_ticket_data[:ticket]
      raise "Response didn't have ticket" if  ticket.blank?
      return ticket
    end

    # 生成随机字符串
    # @param  Integer length 长度, 默认为16
    # @return String
    def generate_noncestr(length=16)
      chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
      str = "";
      chars.chars.each_with_index do |c, index|
        str += chars[rand(chars.length)]
      end
      str
    end
  end
end
