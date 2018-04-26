require 'wechat/api_base'
require 'wechat/http_client'
require 'wechat/token/public_access_token'
require 'wechat/ticket/public_jsapi_ticket'
require 'wechat/concern/common'

module Wechat
  class Api < ApiBase
    include Concern::Common
    WXA_BASE = 'https://api.weixin.qq.com/wxa/'.freeze

    def template_message_send(message)
      post 'message/template/send', message.to_json, content_type: :json
    end
  end
end
