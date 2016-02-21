module ActionController
  module WechatResponder
    def wechat_responder(opts = {})
      include Wechat::Responder

      self.corpid = opts[:corpid] || Wechat.config.corpid
      self.agentid = opts[:agentid] || Wechat.config.agentid
      self.encrypt_mode = opts[:encrypt_mode] || Wechat.config.encrypt_mode || corpid.present?
      self.timeout = opts[:timeout] || 20
      self.skip_verify_ssl = opts[:skip_verify_ssl]
      self.token = opts[:token] || Wechat.config.token
      self.encoding_aes_key = opts[:encoding_aes_key] || Wechat.config.encoding_aes_key
      self.trusted_domain_fullname = opts[:trusted_domain_fullname] || Wechat.config.trusted_domain_fullname

      return self.wechat = Wechat.api if opts.empty?
      return self.wechat = Wechat::CorpApi.new(corpid, opts[:corpsecret], opts[:access_token], \
                                               agentid, timeout, skip_verify_ssl, opts[:jsapi_ticket]) if corpid.present?
      self.wechat = Wechat::Api.new(opts[:appid], opts[:secret], opts[:access_token], \
                                    timeout, skip_verify_ssl, opts[:jsapi_ticket])
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
