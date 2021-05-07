require 'spec_helper'

class WechatController < ActionController::Base
  wechat_responder
end

RSpec.describe WechatController, type: :controller do
  def xml_to_hash(response)
    Hash.from_xml(response.body)['xml'].symbolize_keys
  end

  render_views

  let(:signature_params) do
    timestamp = '1234567'
    nonce = 'nonce'
    signature = Digest::SHA1.hexdigest([ENV['WECHAT_TOKEN'], timestamp, nonce].sort.join)
    { timestamp: timestamp, nonce: nonce, signature: signature }
  end

  let(:message_base) do
    {
      ToUserName: 'toUser',
      FromUserName: 'fromUser',
      CreateTime: '1348831860',
      MsgId: '1234567890123456'
    }
  end

  let(:text_message) { message_base.merge(MsgType: 'text', Content: 'text message') }

  let(:component_verify_ticket_message) do
    {
      AppId: 'some_appid',
      CreateTime: '1348831860',
      InfoType: 'component_verify_ticket',
      ComponentVerifyTicket: 'some_verify_ticket'
    }
  end

  specify 'config responder using global config' do
    expect(controller.class.wechat).to eq(Wechat.api)
    expect(controller.class.token).to eq(Wechat.config.token)
  end

  describe 'config responder using per controller configuration' do
    controller do
      wechat_responder appid: 'controller_appid', secret: 'controller_secret', token: 'controller_token',
                       access_token: 'controller_access_token',
                       agentid: 1, encoding_aes_key: 'encoding_aes_key', trusted_domain_fullname: 'http://your_dev.proxy.qqbrowser.cc'
    end
    specify 'will set controller wechat api and token' do
      access_token = controller.class.wechat.access_token
      expect(access_token.appid).to eq('controller_appid')
      expect(access_token.secret).to eq('controller_secret')
      expect(access_token.token_file).to eq('controller_access_token')
      expect(controller.class.token).to eq('controller_token')
      expect(controller.class.agentid).to eq(1)
      expect(controller.class.encrypt_mode).to eq(false)
      expect(controller.class.encoding_aes_key).to eq('encoding_aes_key')
      expect(controller.class.trusted_domain_fullname).to eq('http://your_dev.proxy.qqbrowser.cc')
    end
  end

  describe 'Verify signature' do
    specify 'on show action' do
      get :show, params: signature_params.merge(signature: 'invalid_signature')
      expect(response.code).to eq('403')
    end

    specify 'on create action' do
      post :create, params: signature_params.merge(signature: 'invalid_signature')
      expect(response.code).to eq('403')
    end
  end

  specify "echo 'echostr' param when show" do
    get :show, params: signature_params.merge(echostr: 'hello')
    expect(response.body).to eq('hello')
  end

  describe 'responders' do
    specify 'responders only accept :text, :image, :voice, :video, :shortvideo, :location, :link, :event, :fallback message type' do
      [:text, :image, :voice, :video, :location, :link, :event, :fallback].each do |message_type|
        controller.class.on message_type, respond: 'response'
      end
    end

    specify 'will raise error if message type is unkonwn' do
      expect { controller.class.on :unkonwn, respond: 'response' }.to raise_error
    end

    specify 'responder take :with argument only for :text and :event message_type' do
      expect(controller.class.on :text, with: 'command', respond: 'response').to eq(with: 'command', respond: 'response')
      expect(controller.class.on :event, with: 'subscribe').to eq(with: 'subscribe')
      expect { controller.class.on :image, with: 'with' }.to raise_error
    end
  end

  describe 'responder_for' do
    controller do
      wechat_responder
      on :text,  with: 'command', respond: 'string matched'
      on :text,  with: /^cmd:(.*)$/, respond: 'regex matched'
      on :text,  respond: 'text content'
      on :event, with: 'subscribe', respond: 'subscribe event'
      on :click, with: 'EVENTKEY', respond: 'EVENTKEY clicked'
      on :image, respond: 'image content'
      on :component, with: 'component_verify_ticket', respond: 'component_verify_ticket event'
    end

    specify 'find first responder for matched type' do
      expect do |b|
        controller.class.responder_for(MsgType: 'image', &b)
      end.to yield_with_args(respond: 'image content')
    end

    specify "find 'general text' responder if none of the text responders matches request content" do
      expect do |b|
        controller.class.responder_for(MsgType: 'text', Content: 'some text', &b)
      end.to yield_with_args({ respond: 'text content' }, 'some text')
    end

    specify "find 'string matched' responder if request content matches string" do
      expect do |b|
        controller.class.responder_for(MsgType: 'text', Content: 'command', &b)
      end.to yield_with_args({ respond: 'string matched', with: 'command' }, 'command')
    end

    specify "find 'regex mached' responder if request content matches regex" do
      expect do |b|
        controller.class.responder_for(MsgType: 'text', Content: 'cmd:my_command', &b)
      end.to yield_with_args({ respond: 'regex matched', with: /^cmd:(.*)$/ }, 'my_command')
    end

    specify "find 'subscribe event' responder if event request matches event" do
      expect do |b|
        controller.class.responder_for(MsgType: 'event', Event: 'subscribe', &b)
      end.to yield_with_args({ respond: 'subscribe event', with: 'subscribe' }, 'subscribe')
    end

    specify "find 'click' responder if event request matches click" do
      expect do |b|
        controller.class.responder_for(MsgType: 'event', Event: 'click', EventKey: 'EVENTKEY', &b)
      end.to yield_with_args({ respond: 'EVENTKEY clicked', with: 'EVENTKEY' }, 'EVENTKEY')
    end

    specify "find 'component_verify_ticket event' responder if event request matches component_verify_ticket" do
      expect do |b|
        controller.class.responder_for(InfoType: 'component_verify_ticket', &b)
      end.to yield_with_args({ respond: 'component_verify_ticket event', with: 'component_verify_ticket' }, 'component_verify_ticket')
    end
  end

  specify 'will respond empty if no responder for the message type' do
    post :create, params: signature_params.merge(xml: text_message)
    expect(response.code).to eq('200')
    expect(response.body.strip).to be_empty
  end

  describe 'respond_to wechat helper' do
    controller do
      wechat_responder
      on :text do |_message, _content|
        wechat
      end
    end

    specify 'will return normal' do
      expect do
        post :create, params: signature_params.merge(xml: text_message)
      end.not_to raise_error
    end
  end

  describe 'respond_to wechat_url helper' do
    controller do
      wechat_responder
      on :text do |_message, _content|
        wechat_url
      end
    end

    specify 'will return normal' do
      expect do
        post :create, params: signature_params.merge(xml: text_message)
      end.not_to raise_error
    end
  end

  describe 'fallback responder' do
    controller do
      wechat_responder
      on :fallback, respond: 'fallback responder'
    end

    specify 'will respond to any message' do
      post :create, params: signature_params.merge(xml: text_message)
      expect(xml_to_hash(response)[:Content]).to eq('fallback responder')
    end
  end

  describe 'fallback responder transfer to customer service' do
    controller do
      wechat_responder
      on :fallback do |message|
        message.reply.transfer_customer_service
      end
    end

    specify 'will change MsgType to transfer_customer_service' do
      post :create, params: signature_params.merge(xml: text_message)
      expect(xml_to_hash(response)[:MsgType]).to eq 'transfer_customer_service'
    end
  end

  describe 'default text transfer to customer service' do
    controller do
      wechat_responder
      on :text do |request, _content|
        request.reply.transfer_customer_service
      end
    end

    specify 'will change MsgType to transfer_customer_service' do
      post :create, params: signature_params.merge(xml: text_message)
      expect(xml_to_hash(response)[:MsgType]).to eq 'transfer_customer_service'
    end
  end

  describe '#create use cases' do
    controller do
      wechat_responder
      on :fallback, respond: 'fallback message'

      on :text, respond: 'text message' do |message, _content|
        message.replay.text('should not be here')
      end

      on :text, with: 'command' do |message, content|
        message.reply.text("text: #{content}")
      end

      on :text, with: 'help' do |message,|
        message.reply.text('help requested')
      end

      on :text, with: /^cmd:(.*)$/ do |message, cmd|
        message.reply.text("cmd: #{cmd}")
      end

      on :text, with: 'session count' do |message|
        message.session.count = message.session.count + 1
        message.reply.text message.session.count
      end

      on :text, with: 'session hash_store count' do |message|
        message.session.hash_store[:count] = message.session.hash_store.fetch(:count, 0) + 1
        message.reply.text message.session.hash_store[:count]
      end

      on :event, with: 'subscribe' do |message, event|
        message.reply.text("event: #{event}")
      end

      on :event, with: 'unsubscribe' do |message|
        message.reply.success
      end

      on :scan, with: 'qrscene_xxxxxx' do |request, ticket|
        request.reply.text "Unsubscribe user #{request[:FromUserName]} Ticket #{ticket}"
      end

      on :scan, with: 'scene_id' do |request, ticket|
        request.reply.text "Subscribe user #{request[:FromUserName]} Ticket #{ticket}"
      end

      on :event, with: 'scan' do |request|
        if request[:EventKey].present?
          request.reply.text "event scan got EventKey #{request[:EventKey]} Ticket #{request[:Ticket]}"
        end
      end

      on :location do |message|
        message.reply.text("Latitude: #{message[:Latitude]} Longitude: #{message[:Longitude]}")
      end

      on :label_location do |message|
        message.reply.text("Label: #{message[:Label]} Location_X: #{message[:Location_X]} Location_Y: #{message[:Location_Y]} Scale: #{message[:Scale]}")
      end

      on :image do |message|
        message.reply.text("image: #{message[:PicUrl]}")
      end

      on :voice do |message|
        message.reply.text("voice: #{message[:MediaId]}")
      end

      on :video do |message|
        message.reply.text("video: #{message[:MediaId]}")
      end

      on :shortvideo do |message|
        message.reply.text("shortvideo: #{message[:MediaId]}")
      end

      on :link do |message|
        message.reply.text("link: #{message[:Url]}")
      end

      on :component, with: 'component_verify_ticket' do |message|
        Wechat::ApiLoader.class_eval { @configs = nil }
        ENV['WECHAT_CONF_FILE'] = File.join(Dir.getwd, 'spec/dummy/config/dummy_wechat.yml')
        Wechat.api(:component).save_verify_ticket(message[:ComponentVerifyTicket], message[:CreateTime])
        message.reply.success
      end
    end

    specify 'response with respond field' do
      post :create, params: signature_params.merge(xml: text_message.merge(Content: 'message'))
      result = xml_to_hash(response)
      expect(result[:ToUserName]).to eq('fromUser')
      expect(result[:FromUserName]).to eq('toUser')
      expect(result[:Content]).to eq('text message')
    end

    specify 'response text with text match' do
      post :create, params: signature_params.merge(xml: text_message.merge(Content: 'command'))
      expect(xml_to_hash(response)[:Content]).to eq('text: command')
    end

    specify 'response text with help and session check' do
      WechatSession.all.delete_all
      post :create, params: signature_params.merge(xml: text_message.merge(Content: 'help'))
      expect(xml_to_hash(response)[:Content]).to eq('help requested')
      expect(WechatSession.first.openid).to eq 'fromUser'
    end

    specify 'response text with regex matched' do
      post :create, params: signature_params.merge(xml: text_message.merge(Content: 'cmd:reload'))
      expect(xml_to_hash(response)[:Content]).to eq('cmd: reload')
    end

    specify 'response text with session count with no session record' do
      WechatSession.all.delete_all
      post :create, params: signature_params.merge(xml: text_message.update(Content: 'session count'))
      expect(xml_to_hash(response)[:Content]).to eq('1')
      expect(WechatSession.first.openid).to eq 'fromUser'
    end

    specify 'response text with session count with existing session record' do
      WechatSession.all.delete_all
      WechatSession.create! openid: text_message[:FromUserName], count: 2
      post :create, params: signature_params.merge(xml: text_message.update(Content: 'session count'))
      expect(xml_to_hash(response)[:Content]).to eq('3')
      expect(WechatSession.first.openid).to eq 'fromUser'
    end

    specify 'response text with session hash_store count with no session record' do
      WechatSession.all.delete_all
      post :create, params: signature_params.merge(xml: text_message.update(Content: 'session hash_store count'))
      expect(xml_to_hash(response)[:Content]).to eq('1')
      expect(WechatSession.first.openid).to eq 'fromUser'
    end

    specify 'response text with session hash_store count with existing session record' do
      WechatSession.all.delete_all
      ws = WechatSession.new openid: text_message[:FromUserName]
      ws.hash_store = { count: 2 }
      ws.save!
      post :create, params: signature_params.merge(xml: text_message.update(Content: 'session hash_store count'))
      expect(xml_to_hash(response)[:Content]).to eq('3')
      expect(WechatSession.first.openid).to eq 'fromUser'
    end

    specify 'response subscribe event with matched event' do
      WechatSession.all.delete_all
      event_message = message_base.merge(MsgType: 'event', Event: 'subscribe', EventKey: 'qrscene_not_exist')
      post :create, params: signature_params.merge(xml: event_message)
      expect(xml_to_hash(response)[:Content]).to eq('event: subscribe')
      expect(WechatSession.first.openid).to eq 'fromUser'
    end

    specify 'response unsubscribe event with matched event' do
      event_message = message_base.merge(MsgType: 'event', Event: 'unsubscribe')
      post :create, params: signature_params.merge(xml: event_message)
      expect(response.code).to eq('200')
      expect(response.body).to eq('success')
    end

    specify 'response subscribe scan event with matched event' do
      event_message = message_base.merge(MsgType: 'event', Event: 'subscribe', EventKey: 'qrscene_xxxxxx')
      post :create, params: signature_params.merge(xml: event_message.merge(Ticket: 'TICKET'))
      expect(xml_to_hash(response)[:Content]).to eq 'Unsubscribe user fromUser Ticket TICKET'
    end

    specify 'response scan event with matched event' do
      event_message = message_base.merge(MsgType: 'event', Event: 'SCAN', EventKey: 'scene_id')
      post :create, params: signature_params.merge(xml: event_message.merge(Ticket: 'TICKET'))
      expect(xml_to_hash(response)[:Content]).to eq 'Subscribe user fromUser Ticket TICKET'
    end

    specify 'response scan event with by_passed scene_id' do
      event_message = message_base.merge(MsgType: 'event', Event: 'SCAN', EventKey: 'scene_id_by_pass_scan_process')
      post :create, params: signature_params.merge(xml: event_message.merge(Ticket: 'TICKET'))
      expect(xml_to_hash(response)[:Content]).to eq 'event scan got EventKey scene_id_by_pass_scan_process Ticket TICKET'
    end

    specify 'response location' do
      message = message_base.merge(MsgType: 'event', Event: 'LOCATION', Latitude: 23.137466, Longitude: 113.352425, Precision: 119.385040)
      post :create, params: signature_params.merge(xml: message)
      expect(xml_to_hash(response)[:Content]).to eq('Latitude: 23.137466 Longitude: 113.352425')
    end

    specify 'response label_location' do
      message = message_base.merge(MsgType: 'location', Location_X: 23.134521, Location_Y: 113.358803, Scale: 20, Label: '位置信息')
      post :create, params: signature_params.merge(xml: message)
      expect(xml_to_hash(response)[:Content]).to eq('Label: 位置信息 Location_X: 23.134521 Location_Y: 113.358803 Scale: 20')
    end

    specify 'response image' do
      image_message = message_base.merge(MsgType: 'image', MediaId: 'image_media_id', PicUrl: 'pic_url')
      post :create, params: signature_params.merge(xml: image_message)
      expect(xml_to_hash(response)[:Content]).to eq('image: pic_url')
    end

    specify 'response voice' do
      message = message_base.merge(MsgType: 'voice', MediaId: 'voice_media_id', Format: 'format')
      post :create, params: signature_params.merge(xml: message)
      expect(xml_to_hash(response)[:Content]).to eq('voice: voice_media_id')
    end

    specify 'response video' do
      message = message_base.merge(MsgType: 'video', MediaId: 'video_media_id', ThumbMediaId: 'thumb_video_media_id')
      post :create, params: signature_params.merge(xml: message)
      expect(xml_to_hash(response)[:Content]).to eq('video: video_media_id')
    end

    specify 'response shortvideo' do
      message = message_base.merge(MsgType: 'shortvideo', MediaId: 'shortvideo_media_id', ThumbMediaId: 'thumb_shortvideo_media_id')
      post :create, params: signature_params.merge(xml: message)
      expect(xml_to_hash(response)[:Content]).to eq('shortvideo: shortvideo_media_id')
    end

    specify 'response link' do
      message = message_base.merge(MsgType: 'link', Url: 'link_url', Title: 'title', Description: 'description')
      post :create, params: signature_params.merge(xml: message)
      expect(xml_to_hash(response)[:Content]).to eq('link: link_url')
    end

    specify 'response success with component_verify_ticket event' do
      post :create, params: signature_params.merge(xml: component_verify_ticket_message)
      expect(response.code).to eq('200')
      expect(response.body).to eq('success')
      expect(Wechat.api(:component).verify_ticket.ticket).to eq(component_verify_ticket_message[:ComponentVerifyTicket])
    end
  end

  describe 'oauth2_page' do
    controller do
      wechat_api
      def oauth2_page
        wechat_oauth2 do |openid|
          render plain: openid
        end
      end
    end

    before(:each) do
      routes.draw { get 'oauth2_page', to: 'wechat#oauth2_page' }
      allow(controller.wechat.jsapi_ticket).to receive(:oauth2_state) {'oauth2_state'}
    end

    it 'will redirect_to tencent page at first visit' do
      get :oauth2_page
      expect(response).to redirect_to(controller.wechat_oauth2)
    end

    it 'will record cookites when tecent oauth2 success' do
      oauth2_result = { 'openid' => 'openid' }
      expect(controller.wechat).to receive(:web_access_token)
        .with('code_id').and_return(oauth2_result)
      get :oauth2_page, params: { code: 'code_id', state: 'oauth2_state' }
      expect(response.body).to eq 'openid'
      expect(cookies.signed_or_encrypted[:we_openid]).to eq 'openid'
    end

    it 'will render page with proper cookies' do
      cookies.signed_or_encrypted[:we_openid] = 'openid'
      get :oauth2_page
      expect(response.body).to eq 'openid'
    end
  end

  describe 'oauth2_page with account' do
    before(:all) do
      Wechat::ApiLoader.class_eval { @configs = nil }
      ENV['WECHAT_CONF_FILE'] = File.join(Dir.getwd, 'spec/dummy/config/dummy_wechat.yml')
    end

    after(:all) do
      Wechat::ApiLoader.class_eval { @configs = nil }
      ENV['WECHAT_CONF_FILE'] = nil
    end

    controller do
      wechat_api
      def oauth2_page
        wechat_oauth2('snsapi_base', nil, :wx2) do |openid|
          render plain: openid
        end
      end
    end

    before(:each) do
      routes.draw { get 'oauth2_page', to: 'wechat#oauth2_page' }
      allow(controller.wechat(:wx2).jsapi_ticket).to receive(:oauth2_state) {'oauth2_state'}
    end

    it 'will redirect_to tencent page at first visit' do
      get :oauth2_page
      expect(response).to redirect_to(controller.wechat_oauth2('snsapi_base', nil, :wx2))
    end

    it 'will record cookites when tecent oauth2 success' do
      oauth2_result = { 'openid' => 'openid' }
      expect(controller.wechat(:wx2)).to receive(:web_access_token)
        .with('code_id').and_return(oauth2_result)
      get :oauth2_page, params: { code: 'code_id', state: 'oauth2_state' }
      expect(response.body).to eq 'openid'
      expect(cookies.signed_or_encrypted[:we_openid]).to eq 'openid'
    end

    it 'will render page with proper cookies' do
      cookies.signed_or_encrypted[:we_openid] = 'openid'
      get :oauth2_page
      expect(response.body).to eq 'openid'
    end
  end
end
