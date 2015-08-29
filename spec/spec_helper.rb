require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

ENV['RAILS_ENV'] ||= 'test'

ENV['WECHAT_APPID'] = 'appid'
ENV['WECHAT_SECRET'] = 'secret'
ENV['WECHAT_TOKEN'] = 'token'

require File.expand_path('../dummy/config/environment', __FILE__)
require 'rspec/rails'

Dir[File.join(File.dirname(__FILE__), '../spec/support/**/*.rb')].sort.each { |f| require f }
RSpec.configure do |config|
  config.mock_with :rspec
  config.infer_base_class_for_anonymous_controllers = true
  config.order = 'random'

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = 'spec/examples.txt'
end

RSpec::Expectations.configuration.warn_about_potential_false_positives = false
