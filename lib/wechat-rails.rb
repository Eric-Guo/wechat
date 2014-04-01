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
    @config ||= OpenStruct.new(
      app_id: ENV["WECHAT_APPID"],
      secret: ENV["WECHAT_SECRET"],
      token: ENV["WECHAT_TOKEN"],
      access_token: ENV["WECHAT_ACCESS_TOKEN"]
    )
  end

  def self.api
    @api ||= Wechat::Api.new(self.config.app_id, self.config.secret, self.config.access_token)
  end
end

if defined? ActionController::Base
  class ActionController::Base
    def self.wechat_rails
      self.send(:include, Wechat::Responder)
    end
  end
end
