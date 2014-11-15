require "wechat/api"

module Wechat
  autoload :Message, "wechat/message"
  autoload :Responder, "wechat/responder"
  autoload :Response, "wechat/response"

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
        config_file = Rails.root.join("config/wechat.yml")
        config = YAML.load(ERB.new(File.new(config_file).read).result)[Rails.env] if (File.exist?(config_file))
      end

      config ||= {appid: ENV["WECHAT_APPID"], secret: ENV["WECHAT_SECRET"], token: ENV["WECHAT_TOKEN"], access_token: ENV["WECHAT_ACCESS_TOKEN"]}
      config.symbolize_keys!
      config[:access_token] ||= Rails.root.join("tmp/access_token").to_s
      OpenStruct.new(config)
    end
  end

  def self.api
    @api ||= Wechat::Api.new(self.config.appid, self.config.secret, self.config.access_token)
  end
end

if defined? ActionController::Base
  class ActionController::Base
    def self.wechat_responder opts={}
      self.send(:include, Wechat::Responder)
      if (opts.empty?)
        self.wechat = Wechat.api
        self.token = Wechat.config.token
      else
        self.wechat = Wechat::Api.new(opts[:appid], opts[:secret], opts[:access_token])
        self.token = opts[:token]
      end
    end
  end
end
