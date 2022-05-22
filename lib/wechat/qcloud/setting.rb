# frozen_string_literal: true

module Wechat
  module Qcloud
    class Setting
      attr_reader :qcloud_env, :qcloud_token, :qcloud_token_lifespan

      def initialize(qcloud_env, qcloud_token, qcloud_token_lifespan)
        @qcloud_env = qcloud_env
        @qcloud_token = qcloud_token
        @qcloud_token_lifespan = qcloud_token_lifespan
      end
    end
  end
end
