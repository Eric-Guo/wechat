require 'wechat/api_base'
require 'wechat/client'
require 'wechat/token/public_access_token'
require 'wechat/ticket/public_jsapi_ticket'

module Wechat
  class Api < ApiBase
    API_BASE = 'https://api.weixin.qq.com/cgi-bin/'
    OAUTH2_BASE = 'https://api.weixin.qq.com/sns/oauth2/'

    def initialize(appid, secret, token_file, timeout, skip_verify_ssl, jsapi_ticket_file)
      @client = Client.new(API_BASE, timeout, skip_verify_ssl)
      @access_token = Token::PublicAccessToken.new(@client, appid, secret, token_file)
      @jsapi_ticket = Ticket::PublicJsapiTicket.new(@client, @access_token, jsapi_ticket_file)
    end

    def groups
      get 'groups/get'
    end

    def group_create(group_name)
      post 'groups/create', JSON.generate(group: { name: group_name })
    end

    def group_update(groupid, new_group_name)
      post 'groups/update', JSON.generate(group: { id: groupid, name: new_group_name })
    end

    def group_delete(groupid)
      post 'groups/delete', JSON.generate(group: { id: groupid })
    end

    def users(nextid = nil)
      params = { params: { next_openid: nextid } } if nextid.present?
      get('user/get', params || {})
    end

    def user(openid)
      get 'user/info', params: { openid: openid }
    end

    def user_group(openid)
      post 'groups/getid', JSON.generate(openid: openid)
    end

    def user_change_group(openid, to_groupid)
      post 'groups/members/update', JSON.generate(openid: openid, to_groupid: to_groupid)
    end

    def user_update_remark(openid, remark)
      post 'user/info/updateremark', JSON.generate(openid: openid, remark: remark)
    end

    def qrcode_create_scene(scene_id, expire_seconds = 604800)
      post 'qrcode/create', JSON.generate(expire_seconds: expire_seconds,
                                          action_name: 'QR_SCENE',
                                          action_info: { scene: { scene_id: scene_id } })
    end

    def qrcode_create_limit_scene(scene_id_or_str)
      case scene_id_or_str
      when Fixnum
        post 'qrcode/create', JSON.generate(action_name: 'QR_LIMIT_SCENE',
                                            action_info: { scene: { scene_id: scene_id_or_str } })
      else
        post 'qrcode/create', JSON.generate(action_name: 'QR_LIMIT_STR_SCENE',
                                            action_info: { scene: { scene_str: scene_id_or_str } })
      end
    end

    def menu
      get 'menu/get'
    end

    def menu_delete
      get 'menu/delete'
    end

    def menu_create(menu)
      # 微信不接受7bit escaped json(eg \uxxxx), 中文必须UTF-8编码, 这可能是个安全漏洞
      post 'menu/create', JSON.generate(menu)
    end

    def material(media_id)
      get 'material/get', params: { media_id: media_id }, as: :file
    end

    def material_count
      get 'material/get_materialcount'
    end

    def material_list(type, offset, count)
      post 'material/batchget_material', JSON.generate(type: type, offset: offset, count: count)
    end

    def material_add(type, file)
      post_file 'material/add_material', file, params: { type: type }
    end

    def material_delete(media_id)
      post 'material/del_material', media_id: media_id
    end

    def custom_message_send(message)
      post 'message/custom/send', message.to_json, content_type: :json
    end

    def template_message_send(message)
      post 'message/template/send', message.to_json, content_type: :json
    end

    # http://mp.weixin.qq.com/wiki/17/c0f37d5704f0b64713d5d2c37b468d75.html
    # 第二步：通过code换取网页授权access_token
    def web_access_token(code)
      params = {
        appid: access_token.appid,
        secret: access_token.secret,
        code: code,
        grant_type: 'authorization_code'
      }
      get 'access_token', params: params, base: OAUTH2_BASE
    end
  end
end
