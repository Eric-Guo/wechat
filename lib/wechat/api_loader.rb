# frozen_string_literal: true

require 'active_support/core_ext/object/blank'

module Wechat
  module ApiLoader
    def self.with(options)
      account = options[:account] || :default
      c = ApiLoader.config(account)

      token_file = options[:token_file] || c.access_token.presence || '/var/tmp/wechat_access_token'
      js_token_file = options[:js_token_file] || c.jsapi_ticket.presence || '/var/tmp/wechat_jsapi_ticket'
      type = options[:type] || c.type

      network_setting = Wechat::NetworkSetting.new(c.timeout, c.skip_verify_ssl, c.proxy_url, c.proxy_port, c.proxy_username, c.proxy_password)
      if c.appid && c.secret && token_file.present?
        if type == 'mp'
          qcloud_env = options[:qcloud_env] || c.qcloud_env
          qcloud_token_file = options[:qcloud_token_file] || c.qcloud_token_file.presence || '/var/tmp/qcloud_access_token'
          qcloud_token_lifespan = options[:qcloud_token_lifespan] || c.qcloud_token_lifespan
          qcloud_setting = Wechat::Qcloud::Setting.new(qcloud_env, qcloud_token_file, qcloud_token_lifespan)
          Wechat::MpApi.new(c.appid, c.secret, token_file, network_setting, js_token_file, qcloud_setting)
        else
          Wechat::Api.new(c.appid, c.secret, token_file, network_setting, js_token_file)
        end
      elsif c.corpid && c.corpsecret && token_file.present?
        Wechat::CorpApi.new(c.corpid, c.corpsecret, token_file, c.agentid, network_setting, js_token_file)
      else
        raise 'Need create ~/.wechat.yml with wechat appid and secret or running at rails root folder so wechat can read config/wechat.yml'
      end
    end

    @configs = nil

    def self.config(account = :default)
      account = :default if account.nil?
      @configs ||= loading_config!
      @configs[account.to_sym] || raise("Wechat configuration for #{account} is missing.")
    end

    def self.reload_config!
      @configs = loading_config!
    end

    def self.load_yaml(result)
      YAML.respond_to?(:unsafe_load) ? YAML.unsafe_load(result) : YAML.safe_load(result)
    end

    private_class_method def self.loading_config!
      configs = config_from_file || config_from_environment
      configs.merge!(config_from_db)

      configs.transform_keys! do |key|
        key.to_sym
      rescue StandardError
        key
      end
      configs.each do |key, cfg|
        raise "wrong wechat configuration format for #{key}" unless cfg.is_a?(Hash)

        cfg.transform_keys! do |key|
          key.to_sym
        rescue StandardError
          key
        end
      end

      if defined?(::Rails)
        configs.each do |_, cfg|
          cfg[:access_token] ||= Rails.root.try(:join, 'tmp/access_token').try(:to_path)
          cfg[:jsapi_ticket] ||= Rails.root.try(:join, 'tmp/jsapi_ticket').try(:to_path)
          cfg[:qcloud_token] ||= Rails.root.try(:join, 'tmp/qcloud_token').try(:to_path)
        end
      end

      configs.each do |_, cfg|
        cfg[:timeout] ||= 20
        cfg[:qcloud_token_lifespan] ||= 7200
        cfg[:have_session_class] ||= class_exists?('WechatSession')
        cfg[:oauth2_cookie_duration] ||= 3600 # 1 hour
      end

      # create config object using raw config data
      cfg_objs = {}
      configs.each do |account, cfg|
        cfg_objs[account] = OpenStruct.new(cfg)
      end
      cfg_objs
    end

    private_class_method def self.config_from_db
      return {} unless class_exists?('WechatConfig')

      environment = defined?(::Rails) ? Rails.env.to_s : ENV.fetch('RAILS_ENV', 'development')
      WechatConfig.get_all_configs(environment)
    end

    private_class_method def self.config_from_file
      if defined?(::Rails)
        config_file = ENV.fetch('WECHAT_CONF_FILE') { Rails.root.join('config', 'wechat.yml') }
        resolve_config_file(config_file, Rails.env.to_s)
      else
        require 'erb'
        rails_config_file = ENV.fetch('WECHAT_CONF_FILE') { File.join(Dir.getwd, 'config', 'wechat.yml') }
        application_config_file = File.join(Dir.getwd, 'config', 'application.yml')
        home_config_file = File.join(Dir.home, '.wechat.yml')
        if File.exist?(rails_config_file)
          rails_env = ENV.fetch('RAILS_ENV', 'development')
          if File.exist?(application_config_file) && !defined?(::Figaro)
            require 'figaro'
            Figaro::Application.new(path: application_config_file, environment: rails_env).load
          end
          config = resolve_config_file(rails_config_file, rails_env)
          if config.present? && (default = config[:default]) && (default['appid'] || default['corpid'])
            puts "Using rails project #{ENV.fetch('WECHAT_CONF_FILE', 'config/wechat.yml')} #{rails_env} setting..."
            return config
          end
        end
        return resolve_config_file(home_config_file, nil) if File.exist?(home_config_file)
      end
    end

    private_class_method def self.resolve_config_file(config_file, env)
      return unless File.exist?(config_file)

      begin
        raw_data = load_yaml(ERB.new(File.read(config_file)).result)
      rescue NameError
        puts "WARNING: If using 'Rails.application.credentials.wechat_secret!' in wechat.yml, you need run in 'rails c' and access via 'Wechat.api' or gem 'figaro' instead."
      end
      configs = {}
      if env
        # Process multiple accounts when env is given
        raw_data.each do |key, value|
          if key == env
            configs[:default] = value
          else
            m = /(.*?)_#{env}$/.match(key)
            configs[m[1].to_sym] = value if m
          end
        end
      else
        # Treat is as one account when env is omitted
        configs[:default] = raw_data
      end
      configs
    end

    private_class_method def self.config_from_environment
      value = { appid: ENV.fetch('WECHAT_APPID', nil),
                secret: ENV.fetch('WECHAT_SECRET', nil),
                corpid: ENV.fetch('WECHAT_CORPID', nil),
                corpsecret: ENV.fetch('WECHAT_CORPSECRET', nil),
                agentid: ENV.fetch('WECHAT_AGENTID', nil),
                token: ENV.fetch('WECHAT_TOKEN', nil),
                access_token: ENV.fetch('WECHAT_ACCESS_TOKEN', nil),
                encrypt_mode: ENV.fetch('WECHAT_ENCRYPT_MODE', nil),
                timeout: ENV.fetch('WECHAT_TIMEOUT', nil),
                skip_verify_ssl: ENV.fetch('WECHAT_SKIP_VERIFY_SSL', nil),
                proxy_url: ENV.fetch('WECHAT_PROXY_URL', nil),
                proxy_port: ENV.fetch('WECHAT_PROXY_PORT', nil),
                proxy_username: ENV.fetch('WECHAT_PROXY_USERNAME', nil),
                proxy_password: ENV.fetch('WECHAT_PROXY_PASSWORD', nil),
                encoding_aes_key: ENV.fetch('WECHAT_ENCODING_AES_KEY', nil),
                jsapi_ticket: ENV.fetch('WECHAT_JSAPI_TICKET', nil),
                qcloud_env: ENV.fetch('WECHAT_QCLOUD_ENV', nil),
                qcloud_token_file: ENV.fetch('WECHAT_QCLOUD_TOKEN', nil),
                qcloud_token_lifespan: ENV.fetch('WECHAT_QCLOUD_TOKEN_LIFESPAN', nil),
                trusted_domain_fullname: ENV.fetch('WECHAT_TRUSTED_DOMAIN_FULLNAME', nil) }
      { default: value }
    end

    private_class_method def self.class_exists?(class_name)
      klass = Module.const_get(class_name)
      klass.is_a?(Class)
    rescue NameError
      false
    end
  end
end
