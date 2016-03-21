require 'spec_helper'

RSpec.describe Wechat::Helpers do
  include Wechat::Helpers
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::TagHelper
  let(:controller) { ActionController::Base.new }

  it '#wechat_config_js' do
    js_hash_result = { timestamp: 'timestamp', noncestr: 'noncestr', signature: 'signature' }
    controller.request = ActionController::TestRequest.new(host: 'test.host')
    expect(Wechat.api.jsapi_ticket).to receive(:signature)
      .with('http://test.host').and_return(js_hash_result)
    expect(wechat_config_js(debug: false, api: %w(hideMenuItems openEnterpriseChat))).to end_with '</script>'
  end
end
