# frozen_string_literal: true

require 'base64'
require 'openssl/cipher'
require 'wechat/api_loader'
require 'wechat/api'
require 'wechat/mp_api'
require 'wechat/corp_api'
require 'wechat/component_api'
require 'wechat/helpers'
require 'action_controller/wechat_responder'

module Wechat
  autoload :Message, 'wechat/message'
  autoload :Responder, 'wechat/responder'
  autoload :Cipher, 'wechat/cipher'
  autoload :ControllerApi, 'wechat/controller_api'

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
    { 'errcode': 41003, 'errmsg': e.message }
  end
end

ActionView::Base.include Wechat::Helpers if defined? ActionView::Base
