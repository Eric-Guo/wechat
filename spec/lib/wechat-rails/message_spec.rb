require 'spec_helper'

describe WechatRails::Message do

  let(:request_base) do
    {
      :ToUserName => "toUser",
      :FromUserName => "fromUser",
      :CreateTime => "1348831860",
      :MsgId => "1234567890123456",
    }
  end

  let(:response_base) do
    {
      :ToUserName => "sender",
      :FromUserName => "receiver",
      :CreateTime => 1348831860,
      :MsgId => "1234567890123456",
    }
  end

  let(:text_request){request_base.merge(:MsgType => "text", :Content => "text message")}
  let(:image_request){request_base.merge(:MsgType => "image", :MediaId=>"media_id", :PicUrl => "pic_url")}
  let(:voice_request){request_base.merge(:MsgType => "voice", :MediaId=>"media_id", :Format=>"format")}
  let(:video_request){request_base.merge(:MsgType => "video", :MediaId=>"media_id", :ThumbMediaId=>"thumb_media_id")}
  let(:location_request){request_base.merge(:MsgType => "location", :Location_X=>"location_x", :Location_Y=>"location_y", :Scale=>"scale", :Label=>"label")}

  describe "fromHash" do
    specify "will create message" do
      message = WechatRails::Message.from_hash(text_request)
      expect(message).to be_a(WechatRails::Message)
      expect(message.message_hash.size).to eq(6)
    end
  end
  
  describe "to" do
    let(:message){WechatRails::Message.from_hash(text_request)}
    specify "will create base message" do
      reply  = WechatRails::Message.to("toUser")
      expect(reply).to be_a(WechatRails::Message)
      expect(reply.message_hash).to include(:ToUserName => "toUser")
      expect(reply.message_hash[:CreateTime]).to be_a(Integer)
    end
  end

  describe "#reply" do
    let(:message){WechatRails::Message.from_hash(text_request)}
    specify "will create base response message" do
      reply  = message.reply
      expect(reply).to be_a(WechatRails::Message)
      expect(reply.message_hash).to include(:FromUserName => "toUser", :ToUserName => "fromUser")
      expect(reply.message_hash[:CreateTime]).to be_a(Integer)
    end
  end

  describe "parse message using as" do
    specify "will raise error when parse message as an unkonwn type" do
      message = WechatRails::Message.from_hash(text_request)
      expect{message.as(:unkown)}.to raise_error
    end

    specify "will get text content" do
      message = WechatRails::Message.from_hash(text_request)
      expect(message.as(:text)).to eq("text message")
    end

    specify "will get image file" do
      message = WechatRails::Message.from_hash(image_request)
      WechatRails.should_receive(:media).with("media_id")
      message.as(:image)
    end

    specify "will get voice file" do
      message = WechatRails::Message.from_hash(voice_request)
      WechatRails.should_receive(:media).with("media_id")
      message.as(:voice)
    end

    specify "will get video file" do
      message = WechatRails::Message.from_hash(video_request)
      WechatRails.should_receive(:media).with("media_id")
      message.as(:video)
    end

    specify "will get location information" do
      message = WechatRails::Message.from_hash(location_request)
      expect(message.as :location).to eq(location_x: "location_x", location_y: "location_y", scale: "scale", label: "label")
    end
  end


  context "altering message fields" do
    let(:message){WechatRails::Message.from_hash(response_base)}
    describe "#to" do
      specify "will update ToUserName field and return self" do
        expect(message.to("a user")).to eq(message)
        expect(message[:ToUserName]).to eq("a user")
      end
    end

    describe "#text" do
      specify "will update MsgType and Content field and return self" do
        expect(message.text("content")).to eq(message)
        expect(message[:MsgType]).to eq("text")
        expect(message[:Content]).to eq("content")
      end
    end

    describe "#image" do
      specify "will update MsgType and MediaId field and return self" do
        expect(message.image("media_id")).to eq(message)
        expect(message[:MsgType]).to eq("image")
        expect(message[:Image][:MediaId]).to eq("media_id")
      end
    end

    describe "#voice" do
      specify "will update MsgType and MediaId field and return self" do
        expect(message.voice("media_id")).to eq(message)
        expect(message[:MsgType]).to eq("voice")
        expect(message[:Voice][:MediaId]).to eq("media_id")
      end
    end

    describe "#video" do
      specify "will update MsgType and MediaId, Title, Description field and return self" do
        expect(message.video("media_id", title: "title", description: "description")).to eq(message)

        expect(message[:MsgType]).to eq("video")
        expect(message[:Video][:MediaId]).to eq("media_id")
        expect(message[:Video][:Title]).to eq("title")
        expect(message[:Video][:Description]).to eq("description")
      end
    end

    describe "#music" do
      specify "will update MsgType and ThumbMediaId, Title, Description field and return self" do
        expect(message.music("thumb_media_id", "music_url", title: "title", description: "description", :HQ_music_url=>"hq_music_url")).to eq(message)

        expect(message[:MsgType]).to eq("music")
        expect(message[:Music][:Title]).to eq("title")
        expect(message[:Music][:Description]).to eq("description")
        expect(message[:Music][:MusicUrl]).to eq("music_url")
        expect(message[:Music][:HQMusicUrl]).to eq("hq_music_url")
        expect(message[:Music][:ThumbMediaId]).to eq("thumb_media_id")
      end
    end

    describe "#news" do
      let(:items){ [{title: "title", description: "description", url: "url", pic_url: "pic_url"}] }

      after :each do
        expect(message[:MsgType]).to eq("news")
        expect(message[:ArticleCount]).to eq(1)
        expect(message[:Articles][0][:item][:Title]).to eq("title")
        expect(message[:Articles][0][:item][:Description]).to eq("description")
        expect(message[:Articles][0][:item][:Url]).to eq("url")
        expect(message[:Articles][0][:item][:PicUrl]).to eq("pic_url")
      end

      specify "when no block is given, whill take the items argument as an array articals hash" do
        message.news(items)
      end

      specify "will update MesageType, ArticleCount, Articles field and return self" do
        message.news(items){|articals, item| articals.item item}
      end

    end

  end

end
