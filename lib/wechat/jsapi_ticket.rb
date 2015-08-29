require 'digest/sha1'

module Wechat
  class JsapiTicket
    attr_reader :client, :access_token, :jsapi_ticket_file, :jsapi_ticket_data

    def initialize(client, access_token, jsapi_ticket_file)
      @client = client
      @access_token = access_token
      @jsapi_ticket_file = jsapi_ticket_file
    end

    #  获取微信 jssdk 签名所需的 jsapi_ticket, 返回具有如下结构的 hash:
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
        if Time.now.to_i - created_at >= expires_in - 3 * 60
          raise 'jsapi_ticket may be expired'
        end
      rescue
        refresh
      end
      valid_ticket(@jsapi_ticket_data)
    end

    # 刷新 jsapi_ticket
    def refresh
      data = client.get('ticket/getticket', params: { access_token: access_token.token, type: 'jsapi' })
      data.merge!(created_at: Time.now.to_i)
      File.open(jsapi_ticket_file, 'w') { |f| f.write(data.to_json) } if valid_ticket(data)
      @jsapi_ticket_data = data
    end

    # 获取 jssdk 签名及注册所需其他参数, 返回具有如下结构的 hash:
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

    private

    def valid_ticket(jsapi_ticket_data)
      ticket = jsapi_ticket_data['ticket'] || jsapi_ticket_data[:ticket]
      raise "Response didn't have ticket" if  ticket.blank?
      ticket
    end
  end
end
