require 'wechat/api_loader'
require 'wechat/api'
require 'wechat/corp_api'
require 'action_controller/wechat_responder'

module Wechat
  autoload :Message, 'wechat/message'
  autoload :Responder, 'wechat/responder'
  autoload :Cipher, 'wechat/cipher'

  class AccessTokenExpiredError < StandardError; end
  class ResponseError < StandardError
    attr_reader :error_code
    def initialize(errcode, errmsg)
      @error_code = errcode
      super "#{errmsg}(#{error_code})"
    end
  end

  attr_reader :config

  def self.config
    @config ||= ApiLoader.loading_config
  end

  def self.api
    if config.corpid.present?
      @api ||= CorpApi.new(config.corpid, config.corpsecret, config.access_token, config.agentid, config.skip_verify_ssl)
    else
      @api ||= Api.new(config.appid, config.secret, config.access_token, config.skip_verify_ssl, config.jsapi_ticket)
    end
  end
end
