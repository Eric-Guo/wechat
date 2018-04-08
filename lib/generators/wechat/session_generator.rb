require 'rails/generators/active_record'

module Wechat
  module Generators
    class SessionGenerator < Rails::Generators::Base
      include ::Rails::Generators::Migration

      desc 'Enable wechat session support'
      source_root File.expand_path('../templates', __FILE__)

      def copy_wechat_sessions_migration
        version = ActiveRecord::Migration.current_version
        source = version >= 5 ? create_migration_with_version(version) : 'db/session_migration.rb'
        migration_template source, 'db/migrate/create_wechat_sessions.rb'
      end

      def copy_wechat_session_model
        template 'app/models/wechat_session.rb'
      end

      private

      def self.next_migration_number(dirname)
        ::ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def create_migration_with_version(version)
        path = File.join(File.dirname(__FILE__), "templates/db/session_migration_with_version.rb")
        File.delete(path) if File.exist?(path)
        source_path = File.join(File.dirname(__FILE__), "templates/db/session_migration.rb")
        text = IO.read(source_path)
        text = text.sub('ActiveRecord::Migration', "ActiveRecord::Migration[#{version}]")
        File.open(path, 'w') { |f| f.write text }
        'db/session_migration_with_version.rb'
      end
    end
  end
end
