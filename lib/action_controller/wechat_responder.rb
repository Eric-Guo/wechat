module ActionController
  module WechatResponder
    def wechat_responder(opts = {})
      include Wechat::Responder

      self.corpid = opts[:corpid] || Wechat.config.corpid
      self.agentid = opts[:agentid] || Wechat.config.agentid
      self.encrypt_mode = opts[:encrypt_mode] || Wechat.config.encrypt_mode || corpid.present?
      self.skip_verify_ssl = opts[:skip_verify_ssl]
      self.token = opts[:token] || Wechat.config.token
      self.encoding_aes_key = opts[:encoding_aes_key] || Wechat.config.encoding_aes_key

      if opts.empty?
        self.wechat = Wechat.api
      else
        if corpid.present?
          self.wechat = Wechat::CorpApi.new(corpid, opts[:corpsecret], opts[:access_token], agentid, skip_verify_ssl)
        else
          self.wechat = Wechat::Api.new(opts[:appid], opts[:secret], opts[:access_token], skip_verify_ssl, opts[:jsapi_ticket])
        end
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
