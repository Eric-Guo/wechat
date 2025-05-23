# frozen_string_literal: true

module Wechat
  module Concern
    module Common
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

      def user_batchget(openids, lang = 'zh-CN')
        post 'user/info/batchget', JSON.generate(user_list: openids.collect { |v| { openid: v, lang: lang } })
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

      def qrcode_create_scene(scene_id_or_str, expire_seconds = 604800)
        case scene_id_or_str
        when 0.class
          post 'qrcode/create', JSON.generate(expire_seconds: expire_seconds,
                                              action_name: 'QR_SCENE',
                                              action_info: { scene: { scene_id: scene_id_or_str } })
        else
          post 'qrcode/create', JSON.generate(expire_seconds: expire_seconds,
                                              action_name: 'QR_STR_SCENE',
                                              action_info: { scene: { scene_str: scene_id_or_str } })
        end
      end

      def qrcode_create_limit_scene(scene_id_or_str)
        case scene_id_or_str
        when 0.class
          post 'qrcode/create', JSON.generate(action_name: 'QR_LIMIT_SCENE',
                                              action_info: { scene: { scene_id: scene_id_or_str } })
        else
          post 'qrcode/create', JSON.generate(action_name: 'QR_LIMIT_STR_SCENE',
                                              action_info: { scene: { scene_str: scene_id_or_str } })
        end
      end

      def shorturl(long_url)
        post 'shorturl', JSON.generate(action: 'long2short', long_url: long_url)
      end

      def message_mass_sendall(message)
        post 'message/mass/sendall', message.to_json
      end

      def message_mass_delete(msg_id)
        post 'message/mass/delete', JSON.generate(msg_id: msg_id)
      end

      def message_mass_preview(message)
        post 'message/mass/preview', message.to_json
      end

      def message_mass_get(msg_id)
        post 'message/mass/get', JSON.generate(msg_id: msg_id)
      end

      def wxa_get_user_phone_number(code)
        # https://developers.weixin.qq.com/miniprogram/dev/OpenApiDoc/user-info/phone-number/getPhoneNumber.html
        post 'business/getuserphonenumber', JSON.generate(code: code), base: Wechat::Api::WXA_BASE
      end

      def wxa_get_wxacode(path, width = 430)
        post 'getwxacode', JSON.generate(path: path, width: width), base: Wechat::Api::WXA_BASE
      end

      def wxa_get_wxacode_unlimit(scene, page = nil, width = 430)
        post 'getwxacodeunlimit', JSON.generate(scene: scene, page: page, width: width), base: Wechat::Api::WXA_BASE
      end

      def wxa_create_qrcode(path, width = 430)
        post 'wxaapp/createwxaqrcode', JSON.generate(path: path, width: width)
      end

      def wxa_msg_sec_check(content)
        post 'msg_sec_check', JSON.generate(content: content), base: Wechat::Api::WXA_BASE
      end

      def wxa_generate_urllink(body_hash)
        # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/url-link/urllink.generate.html
        post 'generate_urllink', JSON.generate(body_hash), base: Wechat::Api::WXA_BASE
      end

      def wxa_generate_shortlink(body_hash)
        post 'genwxashortlink', JSON.generate(body_hash), base: Wechat::Api::WXA_BASE
      end

      def menu
        get 'menu/get'
      end

      def menu_delete
        get 'menu/delete'
      end

      def menu_create(menu)
        # 微信不接受 7bit escaped json(eg \uxxxx)，中文必须 UTF-8 编码，这可能是个安全漏洞
        post 'menu/create', JSON.generate(menu)
      end

      def menu_addconditional(menu)
        # Wechat not accept 7bit escaped json(eg \uxxxx), must using UTF-8, possible security vulnerability?
        post 'menu/addconditional', JSON.generate(menu)
      end

      def menu_trymatch(user_id)
        post 'menu/trymatch', JSON.generate(user_id: user_id)
      end

      def menu_delconditional(menuid)
        post 'menu/delconditional', JSON.generate(menuid: menuid)
      end

      def get_material(media_id)
        post 'material/get_material', JSON.generate(media_id: media_id), as: :file
      end

      def material_count
        get 'material/get_materialcount'
      end

      def material_list(type, offset, count)
        post 'material/batchget_material', JSON.generate(type: type, offset: offset, count: count)
      end

      def material_add(type, file, opts = {})
        params = { type: type }
        params.merge!(description: opts.slice(:title, :introduction).to_json) if type == 'video'

        post_file 'material/add_material', file, params: params
      end

      def material_add_news(mpnews_message)
        post 'material/add_news', mpnews_message.to_json
      end

      def material_delete(media_id)
        post 'material/del_material', JSON.generate(media_id: media_id)
      end

      def custom_message_send(message)
        post 'message/custom/send', message.is_a?(Wechat::Message) ? message.to_json : JSON.generate(message), content_type: :json
      end

      def customservice_getonlinekflist
        get 'customservice/getonlinekflist'
      end

      def tags
        get 'tags/get'
      end

      def tag_create(tag_name)
        post 'tags/create', JSON.generate(tag: { name: tag_name })
      end

      def tag_update(tagid, new_tag_name)
        post 'tags/update', JSON.generate(tag: { id: tagid, name: new_tag_name })
      end

      def tag_delete(tagid)
        post 'tags/delete', JSON.generate(tag: { id: tagid })
      end

      def tag_add_user(tagid, openids)
        post 'tags/members/batchtagging', JSON.generate(openid_list: openids, tagid: tagid)
      end

      def tag_del_user(tagid, openids)
        post 'tags/members/batchuntagging', JSON.generate(openid_list: openids, tagid: tagid)
      end

      def tag(tagid, next_openid = '')
        post 'user/tag/get', JSON.generate(tagid: tagid, next_openid: next_openid)
      end

      def getusersummary(begin_date, end_date)
        post 'getusersummary', JSON.generate(begin_date: begin_date, end_date: end_date), base: Wechat::Api::DATACUBE_BASE
      end

      def getusercumulate(begin_date, end_date)
        post 'getusercumulate', JSON.generate(begin_date: begin_date, end_date: end_date), base: Wechat::Api::DATACUBE_BASE
      end

      def addvoicetorecofortext(voice_id, file, file_format = 'mp3', lang = 'zh_CN')
        post_file 'media/voice/addvoicetorecofortext', file, params: { format: file_format, voice_id: voice_id, lang: lang }
      end

      def queryrecoresultfortext(voice_id, lang = 'zh_CN')
        post 'media/voice/queryrecoresultfortext', nil, params: { voice_id: voice_id, lang: lang }
      end

      def translatecontent(from_content, lfrom = 'zh_CN', lto = 'en_US')
        post 'media/voice/translatecontent', from_content, params: { lfrom: lfrom, lto: lto }
      end

      def web_access_token(code)
        params = {
          appid: access_token.appid,
          secret: access_token.secret,
          code: code,
          grant_type: 'authorization_code'
        }
        client.get 'oauth2/access_token', params: params, base: Wechat::Api::OAUTH2_BASE
      end

      def web_auth_access_token(web_access_token, openid)
        client.get 'auth', params: { access_token: web_access_token, openid: openid }, base: Wechat::Api::OAUTH2_BASE
      end

      def web_refresh_access_token(user_refresh_token)
        params = {
          appid: access_token.appid,
          grant_type: 'refresh_token',
          refresh_token: user_refresh_token
        }
        client.get 'oauth2/refresh_token', params: params, base: Wechat::Api::OAUTH2_BASE
      end

      def web_userinfo(web_access_token, openid, lang = 'zh_CN')
        client.get 'userinfo', params: { access_token: web_access_token, openid: openid, lang: lang }, base: Wechat::Api::OAUTH2_BASE
      end
    end
  end
end
