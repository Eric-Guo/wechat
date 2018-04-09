require 'rails/generators/active_record'
require File.expand_path('../migration_helper', __FILE__)

module Wechat
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      include ::Rails::Generators::Migration
      include Wechat::Generators::MigrationHelper

      desc 'Generate wechat configs in database'
      source_root File.expand_path('../templates', __FILE__)

      def copy_wechat_config_migration
        version = ActiveRecord::VERSION::STRING.to_f
        source = version >= 5 ? create_migration_with_version(version, 'config_migration') : 'db/config_migration.rb'
        migration_template source, 'db/migrate/create_wechat_configs.rb'
      end

      def copy_wechat_config_model
        template 'app/models/wechat_config.rb'
      end

      private

      def self.next_migration_number(dirname)
        ::ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
