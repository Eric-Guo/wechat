module Wechat
  module ApiLoader
    def self.with(options)
      c = loading_config

      token_file = options[:toke_file] || c.access_token || '/var/tmp/wechat_access_token'

      if c.appid && c.secret && token_file.present?
        Wechat::Api.new(c.appid, c.secret, token_file, c.skip_verify_ssl)
      elsif c.corpid && c.corpsecret && token_file.present?
        Wechat::CorpApi.new(c.corpid, c.corpsecret, token_file, c.agentid, c.skip_verify_ssl)
      else
        puts <<-HELP
Need create ~/.wechat.yml with wechat appid and secret
or running at rails root folder so wechat can read config/wechat.yml
HELP
        exit 1
      end
    end

    def self.loading_config
      return @config unless @config.nil?
      config ||= config_from_file || config_from_environment

      if defined?(::Rails)
        config[:access_token] ||= Rails.root.join('tmp/access_token').to_s
        config[:jsapi_ticket] ||= Rails.root.join('tmp/jsapi_ticket').to_s
      end
      config.symbolize_keys!
      @config = OpenStruct.new(config)
    end

    def self.config_from_file
      if defined?(::Rails)
        config_file = Rails.root.join('config/wechat.yml')
        return YAML.load(ERB.new(File.read(config_file)).result)[Rails.env] if File.exist?(config_file)
      else
        rails_config_file = File.join(Dir.getwd, 'config/wechat.yml')
        home_config_file = File.join(Dir.home, '.wechat.yml')
        if File.exist?(rails_config_file)
          config = YAML.load(ERB.new(File.read(rails_config_file)).result)['default']
          if config.present? && (config['appid'] || config['corpid'])
            puts 'Using rails project config/wechat.yml default setting...'
            return config
          end
        end
        if File.exist?(home_config_file)
          return YAML.load ERB.new(File.read(home_config_file)).result
        end
      end
    end

    def self.config_from_environment
      { appid: ENV['WECHAT_APPID'],
        secret: ENV['WECHAT_SECRET'],
        corpid: ENV['WECHAT_CORPID'],
        corpsecret: ENV['WECHAT_CORPSECRET'],
        agentid: ENV['WECHAT_AGENTID'],
        token: ENV['WECHAT_TOKEN'],
        access_token: ENV['WECHAT_ACCESS_TOKEN'],
        encrypt_mode: ENV['WECHAT_ENCRYPT_MODE'],
        skip_verify_ssl: ENV['WECHAT_SKIP_VERIFY_SSL'],
        encoding_aes_key: ENV['WECHAT_ENCODING_AES_KEY'] }
    end
  end
end
