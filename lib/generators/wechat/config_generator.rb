# frozen_string_literal: true

require 'rails/generators/active_record'

module Wechat
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      include ::Rails::Generators::Migration

      desc 'Generate wechat configs in database'
      source_root File.expand_path('templates', __dir__)

      def copy_wechat_config_migration
        migration_template(
          'db/config_migration.rb.erb',
          'db/migrate/create_wechat_configs.rb',
          migration_version: migration_version
        )
      end

      def copy_wechat_config_model
        template 'app/models/wechat_config.rb'
      end

      class << self
        def next_migration_number(dirname)
          ::ActiveRecord::Generators::Base.next_migration_number(dirname)
        end
      end

      private

      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" if Rails.version >= '5.0.0'
      end
    end
  end
end
