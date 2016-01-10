require 'rails/generators/active_record'

module Wechat
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ::Rails::Generators::Migration

      desc 'Install Wechat support files'
      source_root File.expand_path('../templates', __FILE__)

      def copy_config
        template 'config/wechat.yml'
      end

      def add_wechat_route
        route 'resource :wechat, only: [:show, :create]'
      end

      def copy_wechat_controller
        template 'app/controllers/wechats_controller.rb'
      end

      def copy_model_migration
        migration_template 'db/migration.rb', 'db/migrate/create_wechat_logs.rb'
      end

      def self.next_migration_number(dirname)
        ::ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
