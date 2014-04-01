require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

ENV["RAILS_ENV"] ||= 'test'

ENV["WECHAT_APPID"] = "appid"
ENV["WECHAT_SECRET"] = "secret"
ENV["WECHAT_TOKEN"] = "token"

require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'

Dir[File.join(File.dirname(__FILE__), "../spec/support/**/*.rb")].sort.each {|f| require f}
RSpec.configure do |config|
  config.color = true
  config.mock_with :rspec
  config.infer_base_class_for_anonymous_controllers = true
  config.order = "random"
end
