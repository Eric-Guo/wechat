# frozen_string_literal: true

module Wechat
  module Concern
    module Qcloud
      def invokecloudfunction(function_name, post_body)
        post 'invokecloudfunction', post_body, params: { env: qcloud.qcloud_env, name: function_name }, base: Wechat::Api::TCB_BASE
      end
    end
  end
end
