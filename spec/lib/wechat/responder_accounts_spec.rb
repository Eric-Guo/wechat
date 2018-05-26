require 'spec_helper'

class WechatAccountsController < ActionController::Base
  wechat_responder account_from_request: proc { |request| request.params[:account] }
  on :text, with: /^cmd:(.*)$/ do |message, cmd|
    message.reply.text("cmd: #{cmd}")
  end
end

RSpec.describe WechatAccountsController, type: :controller do
  def xml_to_hash(response)
    Hash.from_xml(response.body)['xml'].symbolize_keys
  end

  before(:each) do
    allow(WechatConfig).to receive(:get_all_configs).with(ENV['RAILS_ENV']).and_return(
      account_1: {
        appid: 'appid_1', secret: 'secret_1',
        token: 'token_1', access_token: 'tmp/access_token_1', jsapi_ticket: 'tmp/jsapi_ticket_1'
      },
      account_2: {
        appid: 'appid_2', secret: 'secret_2',
        token: 'token_2', access_token: 'tmp/access_token_2', jsapi_ticket: 'tmp/jsapi_ticket_2'
      }
    )
    Wechat.reload_config!
  end

  after(:each) { Wechat::ApiLoader.class_eval { @configs = nil } }

  render_views

  let(:signature_params_1) do
    timestamp = '111111'
    nonce = 'nonce_1'
    signature = Digest::SHA1.hexdigest(['token_1', timestamp, nonce].sort.join)
    { timestamp: timestamp, nonce: nonce, signature: signature }
  end

  let(:signature_params_2) do
    timestamp = '222222'
    nonce = 'nonce_2'
    signature = Digest::SHA1.hexdigest(['token_2', timestamp, nonce].sort.join)
    { timestamp: timestamp, nonce: nonce, signature: signature }
  end

  let(:text_message) do
    message_base = {
      ToUserName: 'toUser',
      FromUserName: 'fromUser',
      CreateTime: '1348831860',
      MsgId: '1234567890123456'
    }
    message_base.merge(MsgType: 'text', Content: 'text message')
  end

  context 'when there is no account param' do
    it 'uses global config' do
      expect(controller.class.wechat).to eq(Wechat.api)
      expect(controller.class.token).to eq(Wechat.config.token)
    end
  end

  context 'when there is account param' do
    it 'succeeds on correct account' do
      post :create, params: signature_params_1.merge(xml: text_message, account: 'account_1')
      expect(response.code).to eq('200')

      post :create, params: signature_params_2.merge(xml: text_message, account: 'account_2')
      expect(response.code).to eq('200')
    end

    it 'fails on incorrect account' do
      post :create, params: signature_params_1.merge(xml: text_message, account: 'account_2')
      expect(response.code).to eq('403')

      post :create, params: signature_params_2.merge(xml: text_message, account: 'account_1')
      expect(response.code).to eq('403')
    end

    it 'raises error on unspecified account' do
      expect do
        post :create, params: signature_params_1.merge(xml: text_message, account: 'invalid_account')
      end.to raise_error
    end

    it 'responds to message' do
      post :create, params: signature_params_1.merge(xml: text_message.merge(Content: 'cmd:command1'), account: 'account_1')
      expect(xml_to_hash(response)[:Content]).to eq('cmd: command1')
    end
  end
end
