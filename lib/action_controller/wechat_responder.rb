module ActionController
  module WechatResponder
    def wechat_responder(opts = {})
      include Wechat::Responder
      if opts.empty?
        self.corpid = Wechat.config.corpid
        self.wechat = Wechat.api
        self.agentid = Wechat.config.agentid
        self.token = Wechat.config.token
        self.encrypt_mode = Wechat.config.encrypt_mode
        self.encoding_aes_key = Wechat.config.encoding_aes_key
      else
        self.corpid = opts[:corpid]
        if corpid.present?
          self.wechat = Wechat::CorpApi.new(opts[:corpid], opts[:corpsecret], opts[:access_token], opts[:agentid])
          self.encrypt_mode = true
        else
          self.wechat = Wechat::Api.new(opts[:appid], opts[:secret], opts[:access_token], opts[:jsapi_ticket])
          self.encrypt_mode = opts[:encrypt_mode]
        end
        self.agentid = opts[:agentid]
        self.token = opts[:token]
        self.encoding_aes_key = opts[:encoding_aes_key]
      end
    end
  end
end
