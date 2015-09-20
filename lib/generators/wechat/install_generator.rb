module Wechat
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Copy Wechat default files"
      source_root File.expand_path('../templates', __FILE__)

      def copy_config
        template "config/wechat.yml"
      end
    end
  end
end
