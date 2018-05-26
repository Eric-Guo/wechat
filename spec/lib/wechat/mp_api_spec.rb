require 'spec_helper'

RSpec.describe Wechat::MpApi do
  let(:token_file) { Rails.root.join('tmp/access_token') }
  let(:jsapi_ticket_file) { Rails.root.join('tmp/jsapi_ticket') }

  subject do
    Wechat::MpApi.new('appid', 'secret', token_file, 20, false, jsapi_ticket_file)
  end

  before :each do
    allow(subject.access_token).to receive(:token).and_return('access_token')
    allow(subject.jsapi_ticket).to receive(:jsapi_ticket).and_return('jsapi_ticket')
  end

  describe '#template_message_send' do
    specify 'will post message/wxopen/template/send with access_token, and json payload' do
      payload = { touser: 'OPENID',
                  template_id: 'TEMPLATE_ID',
                  page: 'index',
                  form_id: 'FORMID',
                  data: { keyword1: { value: '339208499' },
                          keyword2: { value: '2015年01月05日 12:30' },
                          keyword3: { value: '粤海喜来登酒店' },
                          keyword4: { value: '广州市天河区天河路208号' } },
                  emphasis_keyword: 'keyword1.DATA' }
      response_result = { errcode: 0, errmsg: 'ok' }

      expect(subject.client).to receive(:post)
        .with('message/wxopen/template/send', payload.to_json,
              params: { access_token: 'access_token' }, content_type: :json).and_return(response_result)

      expect(subject.template_message_send(payload)).to eq response_result
    end
  end
end
