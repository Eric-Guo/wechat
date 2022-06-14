# frozen_string_literal: true

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/action_controller")
loader.ignore("#{__dir__}/generators/**/*.rb")
loader.setup

require 'base64'
require 'openssl/cipher'

module Wechat
  class AccessTokenExpiredError < StandardError; end

  class InvalidCredentialError < StandardError; end

  class ResponseError < StandardError
    attr_reader :error_code

    def initialize(errcode, errmsg)
      @error_code = errcode
      super "#{errmsg}(#{error_code})"
    end
  end

  def self.config(account = :default)
    ApiLoader.config(account)
  end

  def self.api(account = :default)
    @wechat_apis ||= {}
    @wechat_apis[account.to_sym] ||= ApiLoader.with(account: account)
  end

  def self.reload_config!
    ApiLoader.reload_config!
  end

  def self.decrypt(encrypted_data, session_key, ivector)
    cipher = OpenSSL::Cipher.new('AES-128-CBC')
    cipher.decrypt

    cipher.key     = Base64.decode64(session_key)
    cipher.iv      = Base64.decode64(ivector)
    decrypted_data = Base64.decode64(encrypted_data)
    JSON.parse(cipher.update(decrypted_data) + cipher.final)
  rescue StandardError => e
    { errcode: 41003, errmsg: e.message }
  end
end

ActionView::Base.include Wechat::Helpers if defined? ActionView::Base
require 'action_controller/wechat_responder' # To make wechat_api and wechat_responder available

module ActionController
  if defined? Base
    ActiveSupport.on_load(:action_controller_base) do
      class << Base
        include WechatResponder
      end
    end
  end
  if defined? API
    ActiveSupport.on_load(:action_controller_api) do
      class << API
        include WechatResponder
      end
    end
  end
end
