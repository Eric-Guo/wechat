# frozen_string_literal: true

require 'wechat/api_base'
require 'wechat/http_client'
require 'wechat/token/public_access_token'
require 'wechat/ticket/public_jsapi_ticket'
require 'wechat/qcloud/token'
require 'wechat/concern/common'
require 'wechat/concern/qcloud'

module Wechat
  class MpApi < ApiBase
    def initialize(appid, secret, token_file, timeout, skip_verify_ssl, jsapi_ticket_file, qcloud_env, qcloud_token_file, qcloud_token_lifespan)
      super()
      @client = HttpClient.new(Wechat::Api::API_BASE, timeout, skip_verify_ssl)
      @access_token = Token::PublicAccessToken.new(@client, appid, secret, token_file)
      @jsapi_ticket = Ticket::PublicJsapiTicket.new(@client, @access_token, jsapi_ticket_file)
      @qcloud = Qcloud::Token.new(@client, @access_token, qcloud_env, qcloud_token_file, qcloud_token_lifespan)
    end

    include Concern::Common
    include Concern::Qcloud

    def add_subscribe_message_template(template_id, keyword_id_list, scene_description = '')
      post 'newtmpl/addtemplate',
           JSON.generate(tid: template_id, kidList: keyword_id_list, sceneDesc: scene_description),
           base: Wechat::Api::WXA_API_BASE
    end

    def delete_subscribe_message_template(template_id)
      post 'newtmpl/deltemplate', JSON.generate(priTmplId: template_id), base: Wechat::Api::WXA_API_BASE
    end

    def get_subscribe_message_category
      get 'newtmpl/getcategory', base: Wechat::Api::WXA_API_BASE
    end

    def get_public_template_keywords(template_id)
      get 'newtmpl/getpubtemplatekeywords',
          params: { tid: template_id },
          base: Wechat::Api::WXA_API_BASE
    end

    def get_public_template_title_list(ids, offset: 0, count: 20)
      get 'newtmpl/getpubtemplatetitles',
          params: { ids: ids, start: offset, limit: count },
          base: Wechat::Api::WXA_API_BASE
    end

    def get_template_list
      get 'newtmpl/gettemplate', base: Wechat::Api::WXA_API_BASE
    end

    def send_subscribe_message(message)
      post 'message/subscribe/send', message.to_json
    end

    def jscode2session(code)
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
