module ActionController
  module WechatResponder
    def wechat_api(opts = {})
      include Wechat::ControllerApi
      self.wechat = load_controller_wechat(opts)
    end

    def wechat_responder(opts = {})
      include Wechat::Responder
      self.wechat = load_controller_wechat(opts)
    end

    private_class_method

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
      self.oauth2_cookie_duration = opts[:oauth2_cookie_duration] || Wechat.config.oauth2_cookie_duration.to_i.seconds || 1.hour

      return self.wechat = Wechat.api if opts.empty?
      if corpid.present?
        Wechat::CorpApi.new(corpid, opts[:corpsecret], opts[:access_token], \
                            agentid, timeout, skip_verify_ssl, opts[:jsapi_ticket])
      else
        Wechat::Api.new(appid, opts[:secret], opts[:access_token], \
                        timeout, skip_verify_ssl, opts[:jsapi_ticket])
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
