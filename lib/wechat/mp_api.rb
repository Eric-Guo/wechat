require 'wechat/api_base'
require 'wechat/http_client'
require 'wechat/token/public_access_token'
require 'wechat/ticket/public_jsapi_ticket'
require 'wechat/concern/common'

module Wechat
  class MpApi < ApiBase
    include Concern::Common

    def template_message_send(message)
      post 'message/wxopen/template/send', message.to_json, content_type: :json
    end


    def login(code)
      params = {
        appid: access_token.appid,
        secret: access_token.secret,
        js_code: code,
        grant_type: 'authorization_code'
      }

      client.get 'jscode2session', params: params, base: OAUTH2_BASE
    end

  end
end
