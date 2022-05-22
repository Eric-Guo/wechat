require 'spec_helper'

RSpec.describe Wechat::MpApi do
  let(:token_file) { Rails.root.join('tmp/access_token') }
  let(:jsapi_ticket_file) { Rails.root.join('tmp/jsapi_ticket') }
  let(:qcloud_token_file) { Rails.root.join('tmp/qcloud_token') }

  subject do
    Wechat::MpApi.new('appid', 'secret', token_file, 20, false, jsapi_ticket_file, Wechat::Qcloud::Setting.new('dev', qcloud_token_file, 7200))
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
                          keyword2: { value: '2015 年 01 月 05 日 12:30' },
                          keyword3: { value: '粤海喜来登酒店' },
                          keyword4: { value: '广州市天河区天河路 208 号' } },
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

  describe '#list_template_library_keywords' do
    specify 'will post wxopen/template/library/get with access_token, and id as params' do
      response_result = {
        errcode: 0,
        errmsg: 'ok',
        id: 'AT0002',
        title: '购买成功通知',
        keyword_list: [
          { keyword_id: 3, name: '购买地点', example: 'TIT 造舰厂' },
          { keyword_id: 4, name: '购买时间', example: '2016 年 6 月 6 日' },
          { keyword_id: 5, name: '物品名称', example: '咖啡' }
        ]
      }

      expect(subject.client).to receive(:post)
        .with('wxopen/template/library/get', { id: 'AT0002' }.to_json,
              params: { access_token: 'access_token' }).and_return(response_result)

      expect(subject.list_template_library_keywords('AT0002')).to eq response_result
    end
  end

  describe '#add_message_template' do
    specify 'will post wxopen/template/add with access_token, and id and keyword_id_list as params' do
      response_result = {
        errcode: 0,
        errmsg: 'ok',
        template_id: 'wDYzYZVxobJivW9oMpSCpuvACOfJXQIoKUm0PY397Tc'
      }

      expect(subject.client).to receive(:post)
        .with('wxopen/template/add', { id: 'AT0002', keyword_id_list: [3, 4, 5] }.to_json,
              params: { access_token: 'access_token' }).and_return(response_result)

      expect(subject.add_message_template('AT0002', [3, 4, 5])).to eq response_result
    end
  end

  describe '#list_message_template' do
    specify 'will post wxopen/template/list with access_token, and offset, count as params' do
      response_result = {
        errcode: 0,
        errmsg: 'ok',
        list: [{ template_id: 'wDYzYZVxobJivW9oMpSCpuvACOfJXQIoKUm0PY397Tc',
                 title: '购买成功通知',
                 content: "购买地点{{keyword1.DATA}}\n购买时间{{keyword2.DATA}}\n物品名称{{keyword3.DATA}}\n",
                 example: "购买地点：TIT 造舰厂\n购买时间：2016 年 6 月 6 日\n物品名称：咖啡\n" }]
      }

      expect(subject.client).to receive(:post)
        .with('wxopen/template/list', { offset: 0, count: 1 }.to_json,
              params: { access_token: 'access_token' }).and_return(response_result)

      expect(subject.list_message_template(count: 1)).to eq response_result
    end
  end

  describe '#del_message_template' do
    specify 'will post wxopen/template/del with access_token, and template_id as params' do
      response_result = {
        errcode: 0,
        errmsg: 'ok'
      }

      expect(subject.client).to receive(:post)
        .with('wxopen/template/del', { template_id: 'wDYzYZVxobJivW9oMpSCpuvACOfJXQIoKUm0PY397Tc' }.to_json,
              params: { access_token: 'access_token' }).and_return(response_result)

      expect(subject.del_message_template('wDYzYZVxobJivW9oMpSCpuvACOfJXQIoKUm0PY397Tc')).to eq response_result
    end
  end

  describe '#subscribe_message_send' do
    specify 'will post message/subscribe/send with access_token, and json payload' do
      payload = { touser: 'OPENID',
                  template_id: 'TEMPLATE_ID',
                  page: 'index',
                  data: {
                    number01: { value: "339208499" },
                    date01: { value: "2015 年 01 月 05 日" },
                    thing01: { value: "粤海喜来登酒店" },
                    thing02: { value: "广州市天河区天河路 208 号" }
                  }
                }
      response_result = { errcode: 0, errmsg: 'ok' }

      expect(subject.client).to receive(:post)
        .with('message/subscribe/send', payload.to_json,
              params: { access_token: 'access_token' }).and_return(response_result)

      expect(subject.subscribe_message_send(payload)).to eq response_result
    end
  end

  describe '#jscode2session' do
    specify 'will get jscode2session with appid, secret js_code and grant_type' do
      response_result = {
        openid: 'OPENID',
        session_key: 'SESSIONKEY',
        unionid: 'UNIONID' # if mini program belongs to open platform
      }

      expect(subject.client).to receive(:get)
        .with('jscode2session', params: { appid: 'appid', secret: 'secret', js_code: 'code', grant_type: 'authorization_code' },
                                base: Wechat::Api::OAUTH2_BASE).and_return(response_result)

      expect(subject.jscode2session('code')).to eq response_result
    end
  end
end
