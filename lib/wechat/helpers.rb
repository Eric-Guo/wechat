module Wechat
  module Helpers
    def wechat_config_js(config_options = {})
      account = config_options[:account]

      # Get domain_name, api and app_id
      if account.blank? || account == controller.class.wechat_cfg_account
        # default account
        domain_name = controller.class.trusted_domain_fullname
        api = controller.wechat
        app_id = controller.class.corpid || controller.class.appid
      else
        # not default account
        config = Wechat.config(account)
        domain_name = config.trusted_domain_fullname
        api = controller.wechat(account)
        app_id = config.corpid || config.appid
      end

      page_url = if domain_name
                   "#{domain_name}#{controller.request.original_fullpath}"
                 else
                   controller.request.original_url
                 end
      page_url = page_url.split('#').first if is_ios? 
      js_hash = api.jsapi_ticket.signature(page_url)

      config_js = <<-WECHAT_CONFIG_JS
wx.config({
  debug: #{config_options[:debug]},
  appId: "#{app_id}",
  timestamp: "#{js_hash[:timestamp]}",
  nonceStr: "#{js_hash[:noncestr]}",
  signature: "#{js_hash[:signature]}",
  jsApiList: ['#{config_options[:api].join("','")}']
});
WECHAT_CONFIG_JS
      javascript_tag config_js, type: 'application/javascript'
    end

    private

    def is_ios?
      controller.request.user_agent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/)
    end
  end
end
