require 'rails/generators/active_record'
require File.expand_path('../migration_helper', __FILE__)

module Wechat
  module Generators
    class SessionGenerator < Rails::Generators::Base
      include ::Rails::Generators::Migration
      include Wechat::Generators::MigrationHelper

      desc 'Enable wechat session support'
      source_root File.expand_path('../templates', __FILE__)

      def copy_wechat_sessions_migration
        version = ActiveRecord::VERSION::STRING.to_f
        source = version >= 5 ? create_migration_with_version(version, 'session_migration') : 'db/session_migration.rb'
        migration_template source, 'db/migrate/create_wechat_sessions.rb'
      end

      def copy_wechat_session_model
        template 'app/models/wechat_session.rb'
      end

      private

      def self.next_migration_number(dirname)
        ::ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
