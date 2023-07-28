# frozen_string_literal: true

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
      page_url = page_url.split('#').first
      js_hash = api.jsapi_ticket.signature(page_url)

      # Field `beta` please check https://developer.work.weixin.qq.com/document/path/90514#%E6%AD%A5%E9%AA%A4%E4%BA%8C%EF%BC%9A%E9%80%9A%E8%BF%87config%E6%8E%A5%E5%8F%A3%E6%B3%A8%E5%85%A5%E6%9D%83%E9%99%90%E9%AA%8C%E8%AF%81%E9%85%8D%E7%BD%AE

      config_js = <<~WECHAT_CONFIG_JS
        wx.config({
          beta: #{config_options[:beta] || false},
          debug: #{config_options[:debug] || false},
          appId: "#{app_id}",
          timestamp: "#{js_hash[:timestamp]}",
          nonceStr: "#{js_hash[:noncestr]}",
          signature: "#{js_hash[:signature]}",
          jsApiList: ['#{config_options[:api]&.join("','")}'],
          openTagList: ['#{config_options[:open_tags]&.join("','")}']
        });
      WECHAT_CONFIG_JS
      javascript_tag config_js, type: 'application/javascript'
    end
  end
end
