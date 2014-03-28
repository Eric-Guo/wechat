require "wechat-rails/api"

module WechatRails
  autoload :Handler, "wechat-rails/handler"
  autoload :Response, "wechat-rails/response"

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
      yaml = ERB.new(File.new(Rails.root.join("config/wechat.yml")).read).result
      OpenStruct.new YAML.load(yaml)[Rails.env]
    end
  end

  def self.api
    @api ||= WechatRails::Api.new(self.config.app_id, self.config.secret)
  end
end

if defined? ActionController::Base
  class ActionController::Base
    def self.wechat_rails
      self.send(:include, WechatRails::Handler)
    end
  end
end
