require 'spec_helper'

class WechatController < ApplicationController
  wechat_responder 
end

describe WechatController, type: :controller do

  def xml_to_hash(response)
    Hash.from_xml(response.body)["xml"].symbolize_keys
  end

  render_views

  let(:signature_params) do
    timestamp = "1234567"
    nonce = "nonce"
    signature = Digest::SHA1.hexdigest([ENV["WECHAT_TOKEN"], timestamp, nonce].sort.join)
    {timestamp: timestamp, nonce: nonce, signature:signature}
  end

  let(:message_base) do
    {
      :ToUserName => "toUser",
      :FromUserName => "fromUser",
      :CreateTime => "1348831860",
      :MsgId => "1234567890123456",
    }
  end

  let(:text_message){message_base.merge(:MsgType => "text", :Content => "text message")}

  specify "config responder using global config" do
    expect(controller.class.wechat).to eq(Wechat.api)
    expect(controller.class.token).to eq(Wechat.config.token)
  end

  describe "config responder using per controller configuration" do 
    controller do
      wechat_responder appid: "controller_appid", secret: "controller_secret", token: "controller_token", access_token:"controller_access_token"
    end
    specify "will set controller wechat api and token" do
      access_token = controller.class.wechat.access_token
      expect(access_token.appid).to eq("controller_appid")
      expect(access_token.secret).to eq("controller_secret")
      expect(access_token.token_file).to eq("controller_access_token")
      expect(controller.class.token).to eq("controller_token")
    end
  end

  describe "Verify signature" do
    specify "on show action" do
      get :show, signature_params.merge(signature:"invalid_signature")
      expect(response.code).to eq("403")
    end

    specify "on create action" do
      post :create, signature_params.merge(signature:"invalid_signature")
      expect(response.code).to eq("403")
    end
  end

  specify "echo 'echostr' param when show" do
    get :show, signature_params.merge(echostr:"hello")
    expect(response.body).to eq("hello")
  end

  describe "responders" do
    specify "responders only accept :text, :image, :voice, :video, :location, :link, :event, :fallback message type" do
      [:text, :image, :voice, :video, :location, :link, :event, :fallback].each do |message_type|
        controller.class.on message_type, respond: "response"
      end
    end

    specify "will raise error if message type is unkonwn" do
      expect{controller.class.on :unkonwn, respond: "response"}.to raise_error
    end

    specify "responder take :with argument only for :text and :event message_type" do
      expect(controller.class.on :text, with: "command", respond: "response").to eq(with: "command", respond: "response")
      expect(controller.class.on :event, with: "subscribe").to eq(with: "subscribe")
      expect{controller.class.on :image, with: "with"}.to raise_error
    end
  end

  describe "responder_for" do
    controller do
      wechat_responder 
      on :text,  with: "command", respond: "string matched"
      on :text,  with: /^cmd:(.*)$/, respond: "regex matched"
      on :text,  respond: "text content"
      on :event, with: "subscribe", respond: "subscribe event"
      on :image, respond: "image content"
    end

    specify "find first responder for matched type" do
      expect{|b|
        controller.class.responder_for(:MsgType=> "image", &b)
      }.to yield_with_args({:respond => "image content"})
    end

    specify "find 'general text' responder if none of the text responders matches request content" do
      expect{|b|
        controller.class.responder_for(:MsgType=> "text", :Content=> "some text", &b)
      }.to yield_with_args({:respond => "text content"}, "some text")
    end

    specify "find 'string matched' responder if request content matches string" do
      expect{|b|
        controller.class.responder_for(:MsgType=> "text", :Content=> "command", &b)
      }.to yield_with_args({:respond => "string matched", with: "command"}, "command")
    end

    specify "find 'regex mached' responder if request content matches regex" do
      expect{|b|
        controller.class.responder_for(:MsgType=> "text", :Content=> "cmd:my_command", &b)
      }.to yield_with_args({:respond => "regex matched", with: /^cmd:(.*)$/}, "my_command")
    end

    specify "find 'subscribe event' responder if event request matches event" do
      expect{|b|
        controller.class.responder_for(:MsgType=> "event", :Event=> "subscribe", &b)
      }.to yield_with_args({:respond => "subscribe event", with: "subscribe"}, "subscribe")
    end

  end

  specify "will respond empty if no responder for the message type" do
    post :create, signature_params.merge(xml: text_message)
    expect(response.code).to eq("200")
    expect(response.body.strip).to be_empty
  end

  describe "fallback responder" do
    controller do
      wechat_responder 
      on :fallback, respond: "fallback responder"
    end

    specify "will respond to any message" do 
      post :create, signature_params.merge(xml: text_message)
      expect(xml_to_hash(response)[:Content]).to eq("fallback responder")
    end
  end


  describe "#create use cases" do

    controller do
      wechat_responder 
      on :text, respond: "text message" do |message, content|
        message.replay.text("should not be here")
      end

      on :text,  with: "command" do |message, content|
        message.reply.text("text: #{content}")
      end

      on :text,  with: /^cmd:(.*)$/ do |message, cmd|
        message.reply.text("text: #{cmd}")
      end

      on :event, with: "subscribe" do |message, event|
        message.reply.text("event: #{event}")
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

      on :location do |message|
        message.reply.text("location: #{message[:Label]}")
      end

      on :link do |message|
        message.reply.text("link: #{message[:Url]}")
      end

    end

    specify "response with respond field" do
      post :create, signature_params.merge(xml: text_message.merge(:Content=>"message"))
      result = xml_to_hash(response)
      expect(result[:ToUserName]).to eq("fromUser")
      expect(result[:FromUserName]).to eq("toUser")
      expect(result[:Content]).to eq("text message")
    end

    specify "response text with text match" do
      post :create, signature_params.merge(xml: text_message.merge(:Content=>"command"))
      expect(xml_to_hash(response)[:Content]).to eq("text: command")
    end

    specify "response text with regex matched" do
      post :create, signature_params.merge(xml: text_message.merge(:Content=>"command"))
      expect(xml_to_hash(response)[:Content]).to eq("text: command")
    end

    specify "response event with matched event" do
      event_message = message_base.merge(:MsgType => "event", :Event=>"VIEW")
      post :create, signature_params.merge(xml: event_message.merge(:Event=>"subscribe"))
      expect(xml_to_hash(response)[:Content]).to eq("event: subscribe")
    end

    specify "response image" do
      image_message = message_base.merge(:MsgType => "image", :MediaId=>"image_media_id", :PicUrl => "pic_url")
      post :create, signature_params.merge(xml: image_message)
      expect(xml_to_hash(response)[:Content]).to eq("image: pic_url")
    end

    specify "response voice" do
      message = message_base.merge(:MsgType => "voice", :MediaId=>"voice_media_id", :Format=>"format")
      post :create, signature_params.merge(xml: message)
      expect(xml_to_hash(response)[:Content]).to eq("voice: voice_media_id")
    end

    specify "response video" do
      message = message_base.merge(:MsgType => "video", :MediaId=>"video_media_id", :ThumbMediaId=>"thumb_media_id")
      post :create, signature_params.merge(xml: message)
      expect(xml_to_hash(response)[:Content]).to eq("video: video_media_id")
    end

    specify "response location" do
      message = message_base.merge(:MsgType => "location", :Location_X=>"location_x", :Location_Y=>"location_y", :Scale=>"scale", :Label=>"label")
      post :create, signature_params.merge(xml: message)
      expect(xml_to_hash(response)[:Content]).to eq("location: label")
    end

    specify "response link" do
      message = message_base.merge(:MsgType => "link", :Url=>"link_url", :Title=>"title", :Description=>"description")
      post :create, signature_params.merge(xml: message)
      expect(xml_to_hash(response)[:Content]).to eq("link: link_url")
    end

  end

end
