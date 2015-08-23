require 'wechat/api'
require 'wechat/corp_api'

module Wechat
  autoload :Message, 'wechat/message'
  autoload :Responder, 'wechat/responder'
  autoload :Response, 'wechat/response'
  autoload :Cipher, 'wechat/cipher'

  class AccessTokenExpiredError < StandardError; end
  class ResponseError < StandardError
    attr_reader :error_code
    def initialize(errcode, errmsg)
      error_code = errcode
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
                   token: ENV['WECHAT_TOKEN'],
                   access_token: ENV['WECHAT_ACCESS_TOKEN'],
                   type: ENV['WECHAT_TYPE'],
                   encrypt_mode: ENV['WECHAT_ENCRYPT_MODE'],
                   encoding_aes_key: ENV['WECHAT_ENCODING_AES_KEY'] }
      config.symbolize_keys!
      config[:access_token] ||= Rails.root.join('tmp/access_token').to_s
      config[:jsapi_ticket] ||= Rails.root.join('tmp/jsapi_ticket').to_s
      OpenStruct.new(config)
    end
  end

  def self.api
    @api ||= Wechat::Api.new(config.appid, config.secret, config.access_token, config.jsapi_ticket)
  end
end

if defined? ActionController::Base
  class ActionController::Base
    def self.wechat_responder(opts = {})
      send(:include, Wechat::Responder)
      if opts.empty?
        self.wechat = Wechat.api
        self.token = Wechat.config.token
        self.type = Wechat.config.type
        self.encrypt_mode = Wechat.config.encrypt_mode
        self.encoding_aes_key = Wechat.config.encoding_aes_key
      else
        self.wechat = Wechat::Api.new(opts[:appid], opts[:secret], opts[:access_token], opts[:jsapi_ticket])
        self.token = opts[:token]
        self.type = opts[:type]
        self.encrypt_mode = opts[:encrypt_mode]
        self.encoding_aes_key = opts[:encoding_aes_key]
      end
    end
  end
end
