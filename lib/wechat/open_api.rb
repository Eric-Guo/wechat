# frozen_string_literal: true

require 'wechat/api_base'
require 'wechat/http_client'
require 'wechat/token/public_access_token'
require 'wechat/ticket/public_jsapi_ticket'
require 'wechat/qcloud/token'
require 'wechat/concern/common'

module Wechat
  class OpenApi < ApiBase
    def initialize(appid, secret, token_file, timeout, skip_verify_ssl)
      super()
      @client = HttpClient.new(Wechat::Api::OPENAPI_BASE, timeout, skip_verify_ssl)
      @access_token = Token::PublicAccessToken.new(@client, appid, secret, token_file)
      @open_appid = appid
      @open_secret = secret
    end

    include Concern::Common

    def start_push_ticket
      post 'component/api_start_push_ticket', {component_appid: @open_appid, component_secret: @open_secret}.to_json, content_type: :json
    end
  end
end
