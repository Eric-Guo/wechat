require 'rails/generators/active_record'

module Wechat
  module Generators
    class SessionGenerator < Rails::Generators::Base
      include ::Rails::Generators::Migration

      desc 'Enable wechat session support'
      source_root File.expand_path('../templates', __FILE__)

      def copy_wechat_sessions_migration
        migration_template 'db/migration.rb', 'db/migrate/create_wechat_sessions.rb'
      end

      private

      def self.next_migration_number(dirname)
        ::ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
