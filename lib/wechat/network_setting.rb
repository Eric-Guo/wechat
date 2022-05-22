# frozen_string_literal: true

module Wechat
  class NetworkSetting
    attr_reader :timeout, :skip_verify_ssl

    def initialize(timeout, skip_verify_ssl)
      @timeout = timeout
      @skip_verify_ssl = skip_verify_ssl
    end
  end
end
