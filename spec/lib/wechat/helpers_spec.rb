require 'spec_helper'

class WechatApiController < ActionController::Base
end

RSpec.describe WechatApiController, type: :controller do
  include Wechat::Helpers
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::TagHelper
  let(:js_hash_result) { { timestamp: 'timestamp', noncestr: 'noncestr', signature: 'signature' } }

  describe '#wechat_config_js with original_url' do
    controller do
      wechat_api
    end

    it '#wechat_config_js' do
      controller.request = ActionController::TestRequest.create
      controller.request.host = 'test.host'
      expect(controller.wechat.jsapi_ticket).to receive(:signature)
        .with('http://test.host').and_return(js_hash_result)
      expect(wechat_config_js(debug: false, api: %w(hideMenuItems openEnterpriseChat))).to end_with '</script>'
    end
  end

  describe '#wechat_config_js with trusted_domain_fullname' do
    controller do
      wechat_api trusted_domain_fullname: 'http://trusted.host'
    end

    it 'called with trusted_domain' do
      controller.request = ActionController::TestRequest.create
      controller.request.host = 'test.host'
      expect(controller.wechat.jsapi_ticket).to receive(:signature)
        .with('http://trusted.host').and_return(js_hash_result)
      expect(wechat_config_js(debug: false, api: %w(hideMenuItems))).to end_with '</script>'
    end
  end
end
