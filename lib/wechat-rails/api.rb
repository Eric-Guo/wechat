require 'wechat-rails/client'
require 'wechat-rails/access_token'

class WechatRails::Api
  attr_reader :app_id, :secret, :access_token, :client

  API_BASE = "https://api.weixin.qq.com/cgi-bin/"
  FILE_BASE = "http://file.api.weixin.qq.com/cgi-bin/"

  def initialize app_id, secret, token_file
    @client = WechatRails::Client.new(API_BASE)
    @access_token = WechatRails::AccessToken.new(@client, app_id, secret, token_file)
  end

  def users
    get("user/get")
  end

  def user openid
    get("user/info", params:{openid: openid})
  end

  def menu
    get("menu/get")
  end

  def menu_delete
    get("menu/delete")
  end

  def menu_create menu
    # 微信不接受7bit escaped json(eg \uxxxx), 中文必须UTF-8编码
    escaped_utf_json = menu.to_json.gsub(/\\u([0-9a-z]{4})/) {|s| [$1.to_i(16)].pack("U")}
    post("menu/create", escaped_utf_json)
  end

  def media media_id
    response = get "media/get", params:{media_id: media_id}, base: FILE_BASE, as: :file
  end

  def media_create type, file
    post "media/upload", {upload:{media: file}}, params:{type: type}, base: FILE_BASE
  end

  def custom_text_message openid, text
    custom_message openid, :text, content: text
  end

  def custom_message openid, message_type, options={}
    data = {
      :touser => openid,
      :msgtype => message_type,
      message_type => options
    }

    post "message/custom/send", data.to_json, :content_type => :json
  end


  protected

  def get path, headers={}
    with_access_token(headers[:params]){|params| client.get path, headers.merge(params: params)}
  end

  def post path, payload, headers = {}
    with_access_token(headers[:params]){|params| client.post path, payload, headers.merge(params: params)}
  end

  def with_access_token params={}, tries=2
    begin
      params ||= {}
      yield(params.merge(access_token: access_token.token))
    rescue WechatRails::AccessTokenExpiredError => ex
      access_token.refresh
      retry unless (tries -= 1).zero?
    end 
  end

end
