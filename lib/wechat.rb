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

if defined? ActionController::Base
  class ActionController::Base
    def self.wechat_responder(opts = {})
      include Wechat::Responder
      if opts.empty?
        self.corpid = Wechat.config.corpid
        self.wechat = Wechat.api
        self.agentid = Wechat.config.agentid
        self.token = Wechat.config.token
        self.encrypt_mode = Wechat.config.encrypt_mode
        self.encoding_aes_key = Wechat.config.encoding_aes_key
      else
        self.corpid = opts[:corpid]
        if corpid.present?
          self.wechat = Wechat::CorpApi.new(opts[:corpid], opts[:corpsecret], opts[:access_token], opts[:agentid])
        else
          self.wechat = Wechat::Api.new(opts[:appid], opts[:secret], opts[:access_token], opts[:jsapi_ticket])
        end
        self.agentid = opts[:agentid]
        self.token = opts[:token]
        self.encrypt_mode = opts[:encrypt_mode]
        self.encoding_aes_key = opts[:encoding_aes_key]
      end
    end
  end
end

if defined? ActionController::API
  class ActionController::API
    def self.wechat_responder(opts = {})
      include Wechat::Responder
      if opts.empty?
        self.corpid = Wechat.config.corpid
        self.wechat = Wechat.api
        self.agentid = Wechat.config.agentid
        self.token = Wechat.config.token
        self.encrypt_mode = Wechat.config.encrypt_mode
        self.encoding_aes_key = Wechat.config.encoding_aes_key
      else
        self.corpid = opts[:corpid]
        if corpid.present?
          self.wechat = Wechat::CorpApi.new(opts[:corpid], opts[:corpsecret], opts[:access_token], opts[:agentid])
        else
          self.wechat = Wechat::Api.new(opts[:appid], opts[:secret], opts[:access_token], opts[:jsapi_ticket])
        end
        self.agentid = opts[:agentid]
        self.token = opts[:token]
        self.encrypt_mode = opts[:encrypt_mode]
        self.encoding_aes_key = opts[:encoding_aes_key]
      end
    end
  end
end
