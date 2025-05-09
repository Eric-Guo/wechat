require 'simplecov'
SimpleCov.start

ENV['RAILS_ENV'] ||= 'test'

ENV['WECHAT_APPID'] = 'appid'
ENV['WECHAT_SECRET'] = 'secret'
ENV['WECHAT_TOKEN'] = 'token'

require File.expand_path('../dummy/config/environment', __FILE__)
require 'rspec/rails'

Dir[File.join(File.dirname(__FILE__), '../spec/support/**/*.rb')].sort.each { |f| require f }
Dir[File.join(File.dirname(__FILE__), '../lib/generators/wechat/templates/app/models/*.rb')].each { |f| require f }
Dir[File.join(File.dirname(__FILE__), '../lib/action_controller/*.rb')].sort.each { |f| require f }

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define do
  # copy from lib/generators/wechat/templates/db/session_migration.rb
  # add count column
  create_table :wechat_sessions do |t|
    t.string :openid, null: false, index: true
    t.string :hash_store
    t.integer :count, default: 0
    t.timestamps null: false
  end

  # copy from lib/generators/wechat/templates/db/config_migration.rb
  create_table :wechat_configs do |t|
    t.string :environment, null: false, default: 'development'
    t.string :account, null: false
    t.string :account_type
    t.boolean :enabled, default: true
    t.string :appid
    t.string :secret
    t.string :corpid
    t.string :corpsecret
    t.integer :agentid
    t.boolean :encrypt_mode
    t.string :encoding_aes_key
    t.string :token, null: false
    t.string :access_token, null: false
    t.string :jsapi_ticket, null: false
    t.boolean :skip_verify_ssl
    t.integer :timeout, default: 20
    t.string :trusted_domain_fullname
    t.timestamps null: false
  end
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.infer_base_class_for_anonymous_controllers = true
  config.order = 'random'

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  config.disable_monkey_patching!
  #   - https://www.jakeworth.com/rspec-describe-vs-describe/
  config.expose_dsl_globally = false

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = true

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = 'spec/examples.txt'
end

RSpec::Expectations.configuration.warn_about_potential_false_positives = false
