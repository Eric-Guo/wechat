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
    @config ||= begin
      if defined? Rails
        config_file = Rails.root.join('config/wechat.yml')
        config = YAML.load(ERB.new(File.new(config_file).read).result)[Rails.env] if File.exist?(config_file)
      end

      config ||= config_from_environment
      config.symbolize_keys!
      config[:access_token] ||= Rails.root.join('tmp/access_token').to_s
      config[:jsapi_ticket] ||= Rails.root.join('tmp/jsapi_ticket').to_s
      OpenStruct.new(config)
    end
  end

  def self.api
    if config.corpid.present?
      @api ||= CorpApi.new(config.corpid, config.corpsecret, config.access_token, config.agentid, config.skip_verify_ssl)
    else
      @api ||= Api.new(config.appid, config.secret, config.access_token, config.skip_verify_ssl, config.jsapi_ticket)
    end
  end

  private

  def self.config_from_environment
    { appid: ENV['WECHAT_APPID'],
      secret: ENV['WECHAT_SECRET'],
      corpid: ENV['WECHAT_CORPID'],
      corpsecret: ENV['WECHAT_CORPSECRET'],
      agentid: ENV['WECHAT_AGENTID'],
      token: ENV['WECHAT_TOKEN'],
      access_token: ENV['WECHAT_ACCESS_TOKEN'],
      encrypt_mode: ENV['WECHAT_ENCRYPT_MODE'],
      skip_verify_ssl: ENV['WECHAT_SKIP_VERIFY_SSL'],
      encoding_aes_key: ENV['WECHAT_ENCODING_AES_KEY'] }
  end
end
