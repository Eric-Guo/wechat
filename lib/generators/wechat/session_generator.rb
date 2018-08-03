require 'rails/generators/active_record'

module Wechat
  module Generators
    class SessionGenerator < Rails::Generators::Base
      include ::Rails::Generators::Migration

      desc 'Enable wechat session support'
      source_root File.expand_path('../templates', __FILE__)

      def copy_wechat_sessions_migration
        migration_template(
            'db/session_migration.rb.erb',
            'db/migrate/create_wechat_sessions.rb',
            {migration_version: migration_version}
        )
      end

      def copy_wechat_session_model
        template 'app/models/wechat_session.rb'
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
