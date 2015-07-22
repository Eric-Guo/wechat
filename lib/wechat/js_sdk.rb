require "wechat/js_ticket"

class Wechat::JsSdk

  attr_reader :client,:access_token,:js_ticket
  API_BASE = "https://api.weixin.qq.com/cgi-bin/"

  def initialize (app_id, secret, token_file, ticket_file)
    @client = Wechat::Client.new(API_BASE)
    @access_token = Wechat::AccessToken.new(@client, app_id, secret, token_file)
    @js_ticket = Wechat::JsTicket.new(@client, @access_token, ticket_file)
    @app_id = app_id
  end

  def config (url, debug = false)
    timestamp = Time.now.to_i
    noncestr = SecureRandom.hex(16)
    # sorted parameter str
    str = "jsapi_ticket=#{@js_ticket.ticket}&noncestr=#{noncestr}&timestamp=#{timestamp}&url=#{url}";
    signature = Digest::SHA1.hexdigest(str)
    {
        :debug => debug,
        :appId => @app_id,
        :nonceStr => noncestr,
        :timestamp => timestamp,
        :url => url,
        :signature => signature,
        :rawString => str
    }

  end
end