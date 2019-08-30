# frozen_string_literal: true

module Wechat
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc 'Install Wechat support files'
      source_root File.expand_path('templates', __dir__)

      def copy_config
        template 'config/wechat.yml'
      end

      def add_wechat_route
        route 'resource :wechat, only: [:show, :create]'
      end

      def copy_wechat_controller
        template 'app/controllers/wechats_controller.rb'
      end
    end
  end
end
