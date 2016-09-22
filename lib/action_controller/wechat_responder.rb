module ActionController
  module WechatResponder
    def wechat_api(opts = {})
      include Wechat::ControllerApi
      self.wechat_api_client = load_controller_wechat(opts)
    end

    def wechat_responder(opts = {})
      include Wechat::Responder
      self.wechat_api_client = load_controller_wechat(opts)
    end

    def wechat
      self.wechat_api_client ||= load_controller_wechat
    end

    private

    def load_controller_wechat(opts = {})
      self.token = opts[:token] || Wechat.config.token
      self.appid = opts[:appid] || Wechat.config.appid
      self.corpid = opts[:corpid] || Wechat.config.corpid
      self.agentid = opts[:agentid] || Wechat.config.agentid
      self.encrypt_mode = opts[:encrypt_mode] || Wechat.config.encrypt_mode || corpid.present?
      self.timeout = opts[:timeout] || 20
      self.skip_verify_ssl = opts[:skip_verify_ssl]
      self.encoding_aes_key = opts[:encoding_aes_key] || Wechat.config.encoding_aes_key
      self.trusted_domain_fullname = opts[:trusted_domain_fullname] || Wechat.config.trusted_domain_fullname
      Wechat.config.oauth2_cookie_duration ||= 1.hour
      self.oauth2_cookie_duration = opts[:oauth2_cookie_duration] || Wechat.config.oauth2_cookie_duration.to_i.seconds

      access_token = opts[:access_token] || Wechat.config.access_token
      jsapi_ticket = opts[:jsapi_ticket] || Wechat.config.jsapi_ticket
      card_api_ticket = opts[:card_api_ticket] || Wechat.config.card_api_ticket

      return self.wechat_api_client = Wechat.api if opts.empty?
      if corpid.present?
        corpsecret = opts[:corpsecret] || Wechat.config.corpsecret
        Wechat::CorpApi.new(corpid, corpsecret, access_token, \
                            agentid, timeout, skip_verify_ssl, jsapi_ticket, card_api_ticket)
      else
        secret = opts[:secret] || Wechat.config.secret
        Wechat::Api.new(appid, secret, access_token, \
                        timeout, skip_verify_ssl, jsapi_ticket, card_api_ticket)
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
