require 'spec_helper'

include Wechat::Cipher

ENCODING_AES_KEY = Base64.encode64 SecureRandom.hex(16)

class WechatCorpController < ActionController::Base
  wechat_responder corpid: 'corpid', corpsecret: 'corpsecret', token: 'token', access_token: 'controller_access_token',
                   agentid: 1, encoding_aes_key: ENCODING_AES_KEY
end

RSpec.describe WechatCorpController, type: :controller do
  render_views

  let(:message_base) do
    {
      ToUserName: 'toUser',
      FromUserName: 'fromUser',
      CreateTime: '1348831860',
      MsgId: '1234567890123456'
    }
  end

  def signature_params(msg = {})
    xml = message_base.merge(msg).to_xml(root: :xml, skip_instruct: true)

    encrypt = Base64.strict_encode64 encrypt(pack(xml, 'appid'), ENCODING_AES_KEY)
    xml = { Encrypt: encrypt }
    timestamp = '1234567'
    nonce = 'nonce'
    msg_signature = Digest::SHA1.hexdigest(['token', timestamp, nonce, xml[:Encrypt]].sort.join)
    { timestamp: timestamp, nonce: nonce, xml: xml, msg_signature: msg_signature }
  end

  def signature_echostr(echostr)
    encrypt_echostr = Base64.strict_encode64 encrypt(pack(echostr, 'appid'), ENCODING_AES_KEY)
    timestamp = '1234567'
    nonce = 'nonce'
    msg_signature = Digest::SHA1.hexdigest(['token', timestamp, nonce, encrypt_echostr].sort.join)
    { timestamp: timestamp, nonce: nonce, echostr: encrypt_echostr, msg_signature: msg_signature }
  end

  def xml_to_hash(xml_message)
    Hash.from_xml(xml_message)['xml'].symbolize_keys
  end

  describe 'Verify signature' do
    it 'on create action faild' do
      post :create, params: signature_params.merge(msg_signature: 'invalid')
      expect(response.code).to eq '403'
    end

    it 'on create action success' do
      post :create, params: signature_params(MsgType: 'voice', Voice: { MediaId: 'mediaID' })
      expect(response.code).to eq '200'
      expect(response.body.length).to eq 0
    end
  end

  specify "echo 'echostr' param when show" do
    get :show, params: signature_echostr('hello')
    expect(response.body).to eq('hello')
  end

  describe 'corp' do
    controller do
      wechat_responder corpid: 'corpid', corpsecret: 'corpsecret', token: 'token', access_token: 'controller_access_token',
                       agentid: 1, encoding_aes_key: ENCODING_AES_KEY, trusted_domain_fullname: 'http://trusted.host'

      on :text do |request, content|
        request.reply.text "echo: #{content}"
      end

      on :text, with: 'news' do |request|
        request.reply.news(0...1) do |article|
          article.item title: 'title', description: 'desc', pic_url: 'http://www.baidu.com/img/bdlogo.gif', url: 'http://www.baidu.com/'
        end
      end

      on :event, with: 'subscribe' do |request|
        request.reply.text 'welcome!'
      end

      on :event, with: 'enter_agent' do |request|
        request.reply.text 'echo: enter_agent'
      end

      on :click, with: 'BOOK_LUNCH' do |request, key|
        request.reply.text "#{request[:FromUserName]} click #{key}"
      end

      on :view, with: 'http://xxx.proxy.qqbrowser.cc/wechat/view_url' do |request, view|
        request.reply.text "#{request[:FromUserName]} view #{view}"
      end

      on :scan, with: 'BINDING_QR_CODE' do |request, scan_result, scan_type|
        request.reply.text "User #{request[:FromUserName]} ScanResult #{scan_result} ScanType #{scan_type}"
      end

      on :scan, with: 'BINDING_BARCODE' do |message, scan_result|
        if scan_result.start_with? 'CODE_39,'
          message.reply.text "User: #{message[:FromUserName]} scan barcode, result is #{scan_result.split(',')[1]}"
        end
      end

      on :batch_job, with: 'replace_user' do |request, batch_job|
        request.reply.text "Replace user job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
      end

      def oauth2_page
        wechat_oauth2 do |userid|
          render plain: userid
        end
      end
    end

    specify 'will set controller wechat api and token' do
      access_token = controller.class.wechat.access_token
      expect(access_token.token_file).to eq 'controller_access_token'
      expect(controller.class.token).to eq 'token'
      expect(controller.class.agentid).to eq 1
      expect(controller.class.encrypt_mode).to eq true
      expect(controller.class.encoding_aes_key).to eq ENCODING_AES_KEY
      expect(controller.class.trusted_domain_fullname).to eq 'http://trusted.host'
    end

    describe 'response' do
      it 'Verify response signature' do
        post :create, params: signature_params(MsgType: 'text', Content: 'hello')
        expect(response.code).to eq '200'
        expect(response.body.empty?).to eq false

        data = Hash.from_xml(response.body)['xml']

        msg_signature = Digest::SHA1.hexdigest [data['TimeStamp'], data['Nonce'], 'token', data['Encrypt']].sort.join
        expect(data['MsgSignature']).to eq msg_signature
      end

      it 'on text' do
        post :create, params: signature_params(MsgType: 'text', Content: 'hello')
        expect(response.code).to eq '200'
        expect(response.body.empty?).to eq false

        data = Hash.from_xml(response.body)['xml']

        xml_message, app_id = unpack(decrypt(Base64.decode64(data['Encrypt']), ENCODING_AES_KEY))
        expect(app_id).to eq 'appid'
        expect(xml_message.empty?).to eq false

        message = Hash.from_xml(xml_message)['xml']
        expect(message['MsgType']).to eq 'text'
        expect(message['Content']).to eq 'echo: hello'
      end

      it 'on news' do
        post :create, params: signature_params(MsgType: 'text', Content: 'news')
        expect(response.code).to eq '200'
        expect(response.body.empty?).to eq false

        data = Hash.from_xml(response.body)['xml']

        xml_message, app_id = unpack(decrypt(Base64.decode64(data['Encrypt']), ENCODING_AES_KEY))

        expect(app_id).to eq 'appid'
        expect(xml_message.empty?).to eq false

        message = Hash.from_xml(xml_message)['xml']
        articles = { 'item' => { 'Title' => 'title',
                                 'Description' => 'desc',
                                 'PicUrl' => 'http://www.baidu.com/img/bdlogo.gif',
                                 'Url' => 'http://www.baidu.com/' } }
        expect(message['MsgType']).to eq 'news'
        expect(message['ArticleCount']).to eq '1'
        expect(message['Articles']).to eq articles
      end

      it 'on subscribe' do
        post :create, params: signature_params(MsgType: 'event', Event: 'subscribe')
        expect(response.code).to eq '200'

        data = Hash.from_xml(response.body)['xml']

        xml_message, app_id = unpack(decrypt(Base64.decode64(data['Encrypt']), ENCODING_AES_KEY))
        expect(app_id).to eq 'appid'
        expect(xml_message.empty?).to eq false

        message = Hash.from_xml(xml_message)['xml']
        expect(message['MsgType']).to eq 'text'
        expect(message['Content']).to eq 'welcome!'
      end

      it 'on enter_agent' do
        post :create, params: signature_params(MsgType: 'event', Event: 'click', EventKey: 'enter_agent')
        expect(response.code).to eq '200'

        data = Hash.from_xml(response.body)['xml']

        xml_message, app_id = unpack(decrypt(Base64.decode64(data['Encrypt']), ENCODING_AES_KEY))
        expect(app_id).to eq 'appid'
        expect(xml_message.empty?).to eq false

        message = Hash.from_xml(xml_message)['xml']
        expect(message['MsgType']).to eq 'text'
        expect(message['Content']).to eq 'echo: enter_agent'
      end

      it 'on click BOOK_LUNCH' do
        post :create, params: signature_params(MsgType: 'event', Event: 'click', EventKey: 'BOOK_LUNCH')
        expect(response.code).to eq '200'

        data = Hash.from_xml(response.body)['xml']

        xml_message, app_id = unpack(decrypt(Base64.decode64(data['Encrypt']), ENCODING_AES_KEY))
        expect(app_id).to eq 'appid'
        expect(xml_message.empty?).to eq false

        message = Hash.from_xml(xml_message)['xml']
        expect(message['MsgType']).to eq 'text'
        expect(message['Content']).to eq 'fromUser click BOOK_LUNCH'
      end

      it 'on view http://xxx.proxy.qqbrowser.cc/wechat/view_url' do
        post :create, params: signature_params(MsgType: 'event', Event: 'view', EventKey: 'http://xxx.proxy.qqbrowser.cc/wechat/view_url')
        expect(response.code).to eq '200'

        data = Hash.from_xml(response.body)['xml']

        xml_message, app_id = unpack(decrypt(Base64.decode64(data['Encrypt']), ENCODING_AES_KEY))
        expect(app_id).to eq 'appid'
        expect(xml_message.empty?).to eq false

        message = Hash.from_xml(xml_message)['xml']
        expect(message['MsgType']).to eq 'text'
        expect(message['Content']).to eq 'fromUser view http://xxx.proxy.qqbrowser.cc/wechat/view_url'
      end

      it 'on BINDING_QR_CODE' do
        post :create, params: signature_params(FromUserName: 'userid', MsgType: 'event', Event: 'scancode_push', EventKey: 'BINDING_QR_CODE',
                                       ScanCodeInfo: { ScanType: 'qrcode', ScanResult: 'scan_result' })
        expect(response.code).to eq '200'

        data = Hash.from_xml(response.body)['xml']

        xml_message, app_id = unpack(decrypt(Base64.decode64(data['Encrypt']), ENCODING_AES_KEY))
        expect(app_id).to eq 'appid'
        expect(xml_message.empty?).to eq false

        message = Hash.from_xml(xml_message)['xml']
        expect(message['MsgType']).to eq 'text'
        expect(message['Content']).to eq 'User userid ScanResult scan_result ScanType qrcode'
      end

      it 'response scancode event with matched event' do
        post :create, params: signature_params(FromUserName: 'userid', MsgType: 'event', Event: 'scancode_waitmsg', EventKey: 'BINDING_BARCODE',
                                       ScanCodeInfo: { ScanType: 'qrcode', ScanResult: 'CODE_39,SAP0D00' })
        expect(response.code).to eq '200'

        data = Hash.from_xml(response.body)['xml']

        xml_message, app_id = unpack(decrypt(Base64.decode64(data['Encrypt']), ENCODING_AES_KEY))
        expect(app_id).to eq 'appid'
        expect(xml_message.empty?).to eq false

        message = Hash.from_xml(xml_message)['xml']
        expect(message['MsgType']).to eq 'text'
        expect(message['Content']).to eq 'User: userid scan barcode, result is SAP0D00'
      end

      it 'on replace_user' do
        post :create, params: signature_params(FromUserName: 'sys', MsgType: 'event', Event: 'batch_job_result',
                                       BatchJob: { JobId: 'job_id', JobType: 'replace_user', ErrCode: 0, ErrMsg: 'ok' })
        expect(response.code).to eq '200'

        data = Hash.from_xml(response.body)['xml']

        xml_message, app_id = unpack(decrypt(Base64.decode64(data['Encrypt']), ENCODING_AES_KEY))
        expect(app_id).to eq 'appid'
        expect(xml_message.empty?).to eq false

        message = Hash.from_xml(xml_message)['xml']
        expect(message['MsgType']).to eq 'text'
        expect(message['Content']).to eq 'Replace user job job_id finished, return code 0, return message ok'
      end

      describe 'oauth2_page' do
        before(:each) do
          routes.draw { get 'oauth2_page', to: 'wechat_corp#oauth2_page' }
          allow(controller.wechat.jsapi_ticket).to receive(:oauth2_state) {'oauth2_state'}
        end

        it 'will redirect_to tencent page at first visit' do
          get :oauth2_page
          expect(response).to redirect_to(controller.wechat_oauth2)
        end

        it 'will record cookites when tecent oauth2 success' do
          oauth2_result = { 'UserId' => 'userid', 'DeviceId' => 'deviceid' }
          expect(controller.wechat).to receive(:getuserinfo)
            .with('code_id').and_return(oauth2_result)
          get :oauth2_page, params: { code: 'code_id', state: 'oauth2_state' }
          expect(response.body).to eq 'userid'
          expect(cookies.signed_or_encrypted[:we_deviceid]).to eq 'deviceid'
        end

        it 'will render page with proper cookies' do
          cookies.signed_or_encrypted[:we_userid] = 'userid'
          cookies.signed_or_encrypted[:we_deviceid] = 'deviceid'
          get :oauth2_page
          expect(response.body).to eq 'userid'
        end
      end
    end
  end
end
