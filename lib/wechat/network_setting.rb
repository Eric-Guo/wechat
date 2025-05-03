# frozen_string_literal: true

module Wechat
  class NetworkSetting
    attr_reader :timeout, :skip_verify_ssl, :proxy_url, :proxy_username, :proxy_password

    def initialize(timeout, skip_verify_ssl, proxy_url, proxy_username, proxy_password)
      @timeout = timeout
      @skip_verify_ssl = skip_verify_ssl
      @proxy_url = proxy_url
      @proxy_username = proxy_username
      @proxy_password = proxy_password
    end
  end
end
