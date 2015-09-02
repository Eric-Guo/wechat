require 'spec_helper'

RSpec.describe Wechat::CorpApi do
  let(:toke_file) { Rails.root.join('tmp/access_token') }

  subject do
    Wechat::CorpApi.new('corpid', 'corpsecret', toke_file, '1')
  end

  before :each do
    allow(subject.access_token).to receive(:token).and_return('access_token')
  end

  describe '#message_send' do
    specify 'will post message with access_token, and json payload' do
      payload = {
        touser: 'openid',
        msgtype: 'text',
        agentid: '1',
        text: { content: 'message content' }
      }

      expect(subject.client).to receive(:post)
        .with('message/send', payload.to_json,
              { content_type: :json, params: { access_token: 'access_token' } }, false).and_return(true)

      expect(subject.message_send 'openid', 'message content').to be true
    end
  end
end
