# frozen_string_literal: true

module Wechat
  class ApiConfig
    attr_reader :appid, :secret, :token_file, :jsapi_ticket_file, :network_setting

    def initialize(appid, secret, token_file, jsapi_ticket_file, network_setting)
      @appid = appid
      @secret = secret
      @token_file = token_file
      @jsapi_ticket_file = jsapi_ticket_file
      @network_setting = network_setting
    end
  end
end
