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

  describe '#list_template_library' do
    specify 'will post wxopen/template/library/list with access_token, and offset, count as params' do
      response_result = {
        errcode: 0,
        errmsg: 'ok',
        list: [
          { id: 'AT0002', title: '购买成功通知' },
          { id: 'AT0003', title: '购买失败通知' },
          { id: 'AT0004', title: '交易提醒' },
          { id: 'AT0005', title: '付款成功通知' },
          { id: 'AT0006', title: '付款失败通知' }
        ],
        total_count: 599
      }

      expect(subject.client).to receive(:post)
        .with('wxopen/template/library/list', { offset: 0, count: 5 }.to_json,
              params: { access_token: 'access_token' }).and_return(response_result)

      expect(subject.list_template_library(count: 5)).to eq response_result
    end
  end
end
