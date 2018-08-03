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
      if opts.key?(:skip_verify_ssl)
        self.skip_verify_ssl = opts[:skip_verify_ssl]
      else
        self.skip_verify_ssl = cfg.skip_verify_ssl
      end

      return Wechat.api if account == :default && opts.empty?

      access_token = opts[:access_token] || cfg.access_token
      jsapi_ticket = opts[:jsapi_ticket] || cfg.jsapi_ticket

      if corpid.present?
        corpsecret = opts[:corpsecret] || cfg.corpsecret
        Wechat::CorpApi.new(corpid, corpsecret, access_token, \
                            agentid, timeout, skip_verify_ssl, jsapi_ticket)
      else
        secret = opts[:secret] || cfg.secret
        Wechat::Api.new(appid, secret, access_token, \
                        timeout, skip_verify_ssl, jsapi_ticket)
      end
    end
  end

  if defined? Base
    class << Base
      include WechatResponder
    end
  end
  if defined? API
    class << API
      include WechatResponder
    end
  end
end
