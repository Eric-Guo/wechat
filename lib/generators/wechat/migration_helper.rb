module Wechat
  module Generators
    module MigrationHelper

      # Rewrite migration file for Rails 5.x
      # Refactored from https://github.com/Eric-Guo/wechat/pull/220
      def self.create_migration_with_version(version, migration_filename)
        path = File.join(File.dirname(__FILE__), "templates/db/#{migration_filename}_with_version.rb")
        File.delete(path) if File.exist?(path)
        source_path = File.join(File.dirname(__FILE__), "templates/db/#{migration_filename}.rb")
        text = IO.read(source_path)
        text = text.sub('ActiveRecord::Migration', "ActiveRecord::Migration[#{version}]")
        File.open(path, 'w') { |f| f.write text }
        "db/#{migration_filename}_with_version.rb"
      end

    end
  end
end
