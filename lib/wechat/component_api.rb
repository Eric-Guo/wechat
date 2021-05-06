# frozen_string_literal: true

require 'wechat/api_base'
require 'wechat/http_client'
require 'wechat/token/component_access_token'
require 'wechat/ticket/component_verify_ticket'
require 'wechat/concern/common'

module Wechat
  class ComponentApi < ApiBase
    attr_reader :component_appid, :component_secret

    def initialize(component_appid, component_secret, component_token_file, component_verify_ticket_file, timeout, skip_verify_ssl)
      super()
      @client = HttpClient.new(Wechat::Api::COMPONENT_API_BASE, timeout, skip_verify_ssl)
      @access_token = Token::ComponentAccessToken.new(@client, component_appid, component_secret, component_token_file, component_verify_ticket_file)
      @component_appid = component_appid
      @component_secret = component_secret
    end

    # include Concern::Common

    def start_push_ticket
      params = {
        component_appid: component_appid, 
        component_secret: component_secret
      }.to_json
      client.post 'api_start_push_ticket', params, base: Wechat::Api::COMPONENT_API_BASE
    end
  end
end
