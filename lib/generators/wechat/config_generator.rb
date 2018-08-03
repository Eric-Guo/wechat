require 'rails/generators/active_record'

module Wechat
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      include ::Rails::Generators::Migration

      desc 'Generate wechat configs in database'
      source_root File.expand_path('../templates', __FILE__)

      def copy_wechat_config_migration
        migration_template(
            'db/config_migration.rb.erb',
            'db/migrate/create_wechat_configs.rb',
            {migration_version: migration_version}
        )
      end

      def copy_wechat_config_model
        template 'app/models/wechat_config.rb'
      end

      private

      def self.next_migration_number(dirname)
        ::ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def migration_version
        if Rails.version >= '5.0.0'
          "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
        end
      end
    end
  end
end
