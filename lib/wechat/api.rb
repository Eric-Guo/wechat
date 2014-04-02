require 'wechat/client'
require 'wechat/access_token'

class Wechat::Api
  attr_reader :access_token, :client

  API_BASE = "https://api.weixin.qq.com/cgi-bin/"
  FILE_BASE = "http://file.api.weixin.qq.com/cgi-bin/"

  def initialize appid, secret, token_file
    @client = Wechat::Client.new(API_BASE)
    @access_token = Wechat::AccessToken.new(@client, appid, secret, token_file)
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
    # 微信不接受7bit escaped json(eg \uxxxx), 中文必须UTF-8编码, 这可能是个安全漏洞
    post("menu/create", JSON.generate(menu))
  end

  def media media_id
    response = get "media/get", params:{media_id: media_id}, base: FILE_BASE, as: :file
  end

  def media_create type, file
    post "media/upload", {upload:{media: file}}, params:{type: type}, base: FILE_BASE
  end

  def custom_message_send message
    post "message/custom/send", message.to_json, content_type: :json
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
    rescue Wechat::AccessTokenExpiredError => ex
      access_token.refresh
      retry unless (tries -= 1).zero?
    end 
  end

end
