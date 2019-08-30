# frozen_string_literal: true

module Wechat
  module Generators
    class RedisStoreGenerator < Rails::Generators::Base
      desc 'Using redis as token/ticket store'
      source_root File.expand_path('templates', __dir__)

      def copy_wechat_redis_initializer
        template 'config/initializers/wechat_redis_store.rb'
      end

      def add_redis_gem
        gem 'redis'
      end
    end
  end
end
