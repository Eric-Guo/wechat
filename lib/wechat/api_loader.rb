module Wechat
  class ApiLoader
    def self.with(options)
      config = loading_config

      appid =  config['appid']
      secret = config['secret']
      corpid = config['corpid']
      corpsecret = config['corpsecret']
      token_file = options[:toke_file] || config['access_token'] || '/var/tmp/wechat_access_token'
      agentid = config['agentid']
      skip_verify_ssl = config['skip_verify_ssl']

      if appid.present? && secret.present? && token_file.present?
        Wechat::Api.new(appid, secret, token_file, skip_verify_ssl)
      elsif corpid.present? && corpsecret.present? && token_file.present?
        Wechat::CorpApi.new(corpid, corpsecret, token_file, agentid, skip_verify_ssl)
      else
        puts <<-HELP
Need create ~/.wechat.yml with wechat appid and secret
or running at rails root folder so wechat can read config/wechat.yml
HELP
        exit 1
      end
    end

    def self.loading_config
      config = {}

      rails_config_file = File.join(Dir.getwd, 'config/wechat.yml')
      home_config_file = File.join(Dir.home, '.wechat.yml')

      if File.exist?(rails_config_file)
        config = YAML.load(ERB.new(File.read(rails_config_file)).result)['default']
        if config.present? && (config['appid'] || config['corpid'])
          puts 'Using rails project config/wechat.yml default setting...'
        else
          config = {}
        end
      end

      if config.blank? && File.exist?(home_config_file)
        config = YAML.load ERB.new(File.read(home_config_file)).result
      end
      config
    end
  end
end
