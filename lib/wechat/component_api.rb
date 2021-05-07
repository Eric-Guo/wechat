# frozen_string_literal: true

require 'wechat/api_base'
require 'wechat/http_client'
require 'wechat/token/component_access_token'
require 'wechat/ticket/component_verify_ticket'
require 'wechat/concern/common'

module Wechat
  class ComponentApi < ApiBase
    attr_reader :component_appid, :component_secret, :component_verify_ticket_file, :verify_ticket

    def initialize(component_appid, component_secret, component_token_file, component_verify_ticket_file, timeout, skip_verify_ssl)
      super()
      @client = HttpClient.new(Wechat::Api::COMPONENT_API_BASE, timeout, skip_verify_ssl)
      @access_token = Token::ComponentAccessToken.new(
          @client,
          component_appid,
          component_secret,
          component_token_file,
          component_verify_ticket_file,
          'component_access_token'
      )
      @verify_ticket = Ticket::ComponentVerifyTicket.new(component_verify_ticket_file)
      @component_appid = component_appid
      @component_secret = component_secret
      @component_verify_ticket_file = component_verify_ticket_file
    end

    def with_access_token(params = {}, tries = 2)
      params ||= {}
      yield(params.merge(component_access_token: access_token.token))
    rescue AccessTokenExpiredError
      access_token.refresh
      retry unless (tries -= 1).zero?
    end

    # include Concern::Common

    def start_push_ticket
      params = {
          component_appid: component_appid,
          component_secret: component_secret
      }.to_json
      client.post 'api_start_push_ticket', params, base: Wechat::Api::COMPONENT_API_BASE
    end

    # update verify ticket
    def save_verify_ticket(ticket, create_time)
      verify_ticket.update({verify_ticket: ticket, create_time: create_time}.stringify_keys)
    end

    # update verify ticket
    def get_pre_auth_code
      get 'api_create_preauthcode', params: {component_appid: component_appid}
    end

    # get auth url, redirect_to should not be encoded
    def get_auth_url(redirect_to)
      result = get_pre_auth_code
      pre_auto_code = result.stringify_keys["pre_auth_code"]
      "https://mp.weixin.qq.com/cgi-bin/componentloginpage?component_appid=#{component_appid}&pre_auth_code=#{pre_auto_code}&redirect_uri=#{URI.encode(redirect_to)}&auth_type=1"
    end
  end
end
