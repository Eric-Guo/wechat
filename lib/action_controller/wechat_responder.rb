# frozen_string_literal: true

module ActionController
  module WechatResponder
    def wechat_api(opts = {})
      include Wechat::ControllerApi
      account = opts.delete(:account)
      self.wechat_cfg_account = account ? account.to_sym : :default
      self.wechat_api_client = load_controller_wechat(wechat_cfg_account, opts)
    end

    def wechat_responder(opts = {})
      include Wechat::Responder
      account = opts.delete(:account)
      self.account_from_request = opts.delete(:account_from_request)
      self.wechat_cfg_account = account ? account.to_sym : :default
      self.wechat_api_client = load_controller_wechat(wechat_cfg_account, opts)
    end

    def wechat(account = nil)
      if account && account != wechat_cfg_account
        Wechat.api(account)
      else
        self.wechat_api_client ||= load_controller_wechat(wechat_cfg_account)
      end
    end

    private

    def load_controller_wechat(account, opts = {})
      cfg = Wechat.config(account)
      self.token = opts[:token] || cfg.token
      self.appid = opts[:appid] || cfg.appid
      self.corpid = opts[:corpid] || cfg.corpid
      self.agentid = opts[:agentid] || cfg.agentid
      self.encrypt_mode = opts[:encrypt_mode] || cfg.encrypt_mode || corpid.present?
      self.encoding_aes_key = opts[:encoding_aes_key] || cfg.encoding_aes_key
      self.trusted_domain_fullname = opts[:trusted_domain_fullname] || cfg.trusted_domain_fullname
      self.oauth2_cookie_duration = opts[:oauth2_cookie_duration] || cfg.oauth2_cookie_duration.to_i.seconds
      self.timeout = opts[:timeout] || cfg.timeout
      self.skip_verify_ssl = opts.key?(:skip_verify_ssl) ? opts[:skip_verify_ssl] : cfg.skip_verify_ssl

      proxy_url = opts.key?(:proxy_url) ? opts[:proxy_url] : cfg.proxy_url
      proxy_username = opts.key?(:proxy_username) ? opts[:proxy_username] : cfg.proxy_username
      proxy_password = opts.key?(:proxy_password) ? opts[:proxy_password] : cfg.proxy_password

      return Wechat.api if account == :default && opts.empty?

      access_token = opts[:access_token] || cfg.access_token
      jsapi_ticket = opts[:jsapi_ticket] || cfg.jsapi_ticket
      qcloud_env = opts[:qcloud_env] || cfg.qcloud_env
      qcloud_token = opts[:qcloud_token] || cfg.qcloud_token
      qcloud_token_lifespan = opts[:qcloud_token_lifespan] || cfg.qcloud_token_lifespan

      api_type = opts[:type] || cfg.type
      secret = corpid.present? ? opts[:corpsecret] || cfg.corpsecret : opts[:secret] || cfg.secret

      network_setting = Wechat::NetworkSetting.new(timeout, skip_verify_ssl, proxy_url, proxy_username, proxy_password)
      # access_token is token_file, jsapi_ticket is jsapi_ticket_file
      api_config = Wechat::ApiConfig.new(corpid.presence || appid, secret, access_token, jsapi_ticket, network_setting)
      qcloud_setting = Wechat::Qcloud::Setting.new(qcloud_env, qcloud_token, qcloud_token_lifespan)
      get_wechat_api(api_type, api_config, agentid, qcloud_setting)
    end

    def get_wechat_api(api_type, api_config, agentid, qcloud_setting)
      if api_type && api_type.to_sym == :mp
        Wechat::MpApi.new(api_config, qcloud_setting)
      elsif api_config.appid.present? && agentid.present? # Assuming corpid is now in api_config.appid for CorpApi
        Wechat::CorpApi.new(api_config, agentid)
      else
        Wechat::Api.new(api_config)
      end
    end
  end
end
