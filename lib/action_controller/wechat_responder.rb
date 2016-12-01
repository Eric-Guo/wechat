module ActionController
  module WechatResponder
    def wechat_api(opts = {})
      include Wechat::ControllerApi
      self.wechat_cfg_account = opts[:account].present? ? opts[:account].to_sym : :default
      self.wechat_api_client = load_controller_wechat(wechat_cfg_account, opts)
    end

    def wechat_responder(opts = {})
      include Wechat::Responder
      self.wechat_cfg_account = opts[:account].present? ? opts[:account].to_sym : :default
      self.wechat_api_client = load_controller_wechat(wechat_cfg_account, opts)
    end

    def wechat
      self.wechat_api_client ||= load_controller_wechat(wechat_cfg_account)
    end

    private

    def load_controller_wechat(account, opts = {})
      self.token = opts[:token] || Wechat.config(account).token
      self.appid = opts[:appid] || Wechat.config(account).appid
      self.corpid = opts[:corpid] || Wechat.config(account).corpid
      self.agentid = opts[:agentid] || Wechat.config(account).agentid
      self.encrypt_mode = opts[:encrypt_mode] || Wechat.config(account).encrypt_mode || corpid.present?
      self.timeout = opts[:timeout] || 20
      self.skip_verify_ssl = opts[:skip_verify_ssl]
      self.encoding_aes_key = opts[:encoding_aes_key] || Wechat.config(account).encoding_aes_key
      self.trusted_domain_fullname = opts[:trusted_domain_fullname] || Wechat.config(account).trusted_domain_fullname
      Wechat.config(account).oauth2_cookie_duration ||= 1.hour
      self.oauth2_cookie_duration = opts[:oauth2_cookie_duration] || Wechat.config(account).oauth2_cookie_duration.to_i.seconds

      access_token = opts[:access_token] || Wechat.config(account).access_token
      jsapi_ticket = opts[:jsapi_ticket] || Wechat.config(account).jsapi_ticket

      return self.wechat_api_client = Wechat.api if account == :default && opts.empty?

      if corpid.present?
        corpsecret = opts[:corpsecret] || Wechat.config(account).corpsecret
        Wechat::CorpApi.new(corpid, corpsecret, access_token, \
                            agentid, timeout, skip_verify_ssl, jsapi_ticket)
      else
        secret = opts[:secret] || Wechat.config(account).secret
        Wechat::Api.new(appid, secret, access_token, \
                        timeout, skip_verify_ssl, jsapi_ticket)
      end
    end
  end

  if defined? Base
    class << Base
      include WechatResponder
    end
  elsif defined? API
    class << API
      include WechatResponder
    end
  end
end
