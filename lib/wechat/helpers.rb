module Wechat
  module Helpers
    def wechat_config_js(config_options = {})
      page_url = if Wechat.config.trusted_domain_fullname
                   "#{Wechat.config.trusted_domain_fullname}#{controller.request.original_fullpath}"
                 else
                   controller.request.original_url
                 end
      js_hash = Wechat.api.jsapi_ticket.signature(page_url)
      config_js = <<-WECHAT_CONFIG_JS
wx.config({
  debug: #{config_options[:debug]},
  appId: "#{Wechat.config.corpid || Wechat.config.appid}",
  timestamp: "#{js_hash[:timestamp]}",
  nonceStr: "#{js_hash[:noncestr]}",
  signature: "#{js_hash[:signature]}",
  jsApiList: ['#{config_options[:api].join("','")}']
});
WECHAT_CONFIG_JS
      javascript_tag config_js, type: 'application/javascript'
    end
  end
end
