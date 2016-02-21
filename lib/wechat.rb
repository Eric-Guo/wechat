require 'wechat/api_loader'
require 'wechat/api'
require 'wechat/corp_api'
require 'wechat/helpers'
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

  def self.config
    ApiLoader.config
  end

  def self.api
    @wechat_api ||= ApiLoader.with({})
  end
end

ActionView::Base.send :include, Wechat::Helpers if defined? ActionView::Base
