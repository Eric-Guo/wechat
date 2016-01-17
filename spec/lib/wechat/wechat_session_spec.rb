require 'spec_helper'

RSpec.describe Wechat::WechatSession do
  describe '#find_by_openid' do
    specify 'should return same data without from and to order' do
      Wechat::WechatSession.create from_openid: 'from', to_openid: 'to', session_raw: { a: 1 }

      expect(Wechat::WechatSession.find_by_openid('from', 'to').id).to eq(Wechat::WechatSession.find_by_openid('to', 'from').id)
    end
  end
end
