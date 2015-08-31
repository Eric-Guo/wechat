require 'wechat/api'
require 'wechat/corp_api'

module Wechat
  autoload :Message, 'wechat/message'
  autoload :Responder, 'action_controller/responder'
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

      config ||= { appid: ENV['WECHAT_APPID'],
                   secret: ENV['WECHAT_SECRET'],
                   corpid: ENV['WECHAT_CORPID'],
                   corpsecret: ENV['WECHAT_CORPSECRET'],
                   agentid: ENV['WECHAT_AGENTID'],
                   token: ENV['WECHAT_TOKEN'],
                   access_token: ENV['WECHAT_ACCESS_TOKEN'],
                   encrypt_mode: ENV['WECHAT_ENCRYPT_MODE'],
                   encoding_aes_key: ENV['WECHAT_ENCODING_AES_KEY'] }
      config.symbolize_keys!
      config[:access_token] ||= Rails.root.join('tmp/access_token').to_s
      config[:jsapi_ticket] ||= Rails.root.join('tmp/jsapi_ticket').to_s
      OpenStruct.new(config)
    end
  end

  def self.api
    if config.corpid.present?
      @api ||= Wechat::CorpApi.new(config.corpid, config.corpsecret, config.access_token, config.agentid)
    else
      @api ||= Wechat::Api.new(config.appid, config.secret, config.access_token, config.jsapi_ticket)
    end
  end
end

require 'action_controller/wechat_responder'

if defined? ActionController::Base
  class << ActionController::Base
    include ActionController::WechatResponder
  end
end

if defined? ActionController::API
  class << ActionController::API
    include ActionController::WechatResponder
  end
end
