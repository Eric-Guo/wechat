require 'spec_helper'

describe Wechat::Message do
  let(:text_request){request_base.merge(:MsgType => "text", :Content => "text message")}

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

  describe "fromHash" do
    specify "will create message" do
      message = Wechat::Message.from_hash(text_request)
      expect(message).to be_a(Wechat::Message)
      expect(message.message_hash.size).to eq(6)
    end
  end

  describe "to" do
    let(:message){Wechat::Message.from_hash(text_request)}
    specify "will create base message" do
      reply  = Wechat::Message.to("toUser")
      expect(reply).to be_a(Wechat::Message)
      expect(reply.message_hash).to include(:ToUserName => "toUser")
      expect(reply.message_hash[:CreateTime]).to be_a(Integer)
    end
  end

  describe "#reply" do
    let(:message){Wechat::Message.from_hash(text_request)}
    specify "will create base response message" do
      reply  = message.reply
      expect(reply).to be_a(Wechat::Message)
      expect(reply.message_hash).to include(:FromUserName => "toUser", :ToUserName => "fromUser")
      expect(reply.message_hash[:CreateTime]).to be_a(Integer)
    end
  end

  describe "parse message using as" do
    let(:image_request){request_base.merge(:MsgType => "image", :MediaId=>"media_id", :PicUrl => "pic_url")}
    let(:voice_request){request_base.merge(:MsgType => "voice", :MediaId=>"media_id", :Format=>"format")}
    let(:video_request){request_base.merge(:MsgType => "video", :MediaId=>"media_id", :ThumbMediaId=>"thumb_media_id")}
    let(:location_request){request_base.merge(:MsgType => "location", :Location_X=>"location_x", :Location_Y=>"location_y", :Scale=>"scale", :Label=>"label")}

    specify "will raise error when parse message as an unkonwn type" do
      message = Wechat::Message.from_hash(text_request)
      expect{message.as(:unkown)}.to raise_error
    end

    specify "will get text content" do
      message = Wechat::Message.from_hash(text_request)
      expect(message.as(:text)).to eq("text message")
    end

    specify "will get image file" do
      message = Wechat::Message.from_hash(image_request)
      expect(Wechat.api).to receive(:media).with("media_id")
      message.as(:image)
    end

    specify "will get voice file" do
      message = Wechat::Message.from_hash(voice_request)
      expect(Wechat.api).to receive(:media).with("media_id")
      message.as(:voice)
    end

    specify "will get video file" do
      message = Wechat::Message.from_hash(video_request)
      expect(Wechat.api).to receive(:media).with("media_id")
      message.as(:video)
    end

    specify "will get location information" do
      message = Wechat::Message.from_hash(location_request)
      expect(message.as :location).to eq(location_x: "location_x", location_y: "location_y", scale: "scale", label: "label")
    end
  end


  context "altering message fields" do
    let(:message){Wechat::Message.from_hash(response_base)}
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
        expect(message[:Articles][0][:Title]).to eq("title")
        expect(message[:Articles][0][:Description]).to eq("description")
        expect(message[:Articles][0][:Url]).to eq("url")
        expect(message[:Articles][0][:PicUrl]).to eq("pic_url")
      end

      specify "when no block is given, whill take the items argument as an array articals hash" do
        message.news(items)
      end

      specify "will update MesageType, ArticleCount, Articles field and return self" do
        message.news(items){|articals, item| articals.item item}
      end

    end

    describe "#to_xml" do
      let(:response){Wechat::Message.from_hash(response_base)}

      specify "root is xml tag" do
        hash = Hash.from_xml(response.text("text content").to_xml)
        expect(hash.keys).to eq(["xml"])
      end

      specify "collection key is item" do
        xml = response.news([
          {title: "title1", description: "description", url: "url", pic_url: "pic_url"},
          {title: "title2", description: "description", url: "url", pic_url: "pic_url"}
        ]).to_xml

        hash = Hash.from_xml(xml)
        expect(hash["xml"]["Articles"]["item"]).to be_a(Array)
        expect(hash["xml"]["Articles"]["item"].size).to eq(2)
      end
    end

    describe "#to_json" do
      specify "can convert text message" do
        request = Wechat::Message.to("toUser").text("text content")
        expect(request.to_json).to eq({
          "touser" => "toUser",
          "msgtype" => "text",
          "text" => {"content"=>"text content"}
        }.to_json)
      end

      specify "can convert image message" do
        request = Wechat::Message.to("toUser").image("media_id")
        expect(request.to_json).to eq({
          "touser" => "toUser",
          "msgtype" => "image",
          "image" => {"media_id"=>"media_id"}
        }.to_json)
      end

      specify "can convert voice message" do
        request = Wechat::Message.to("toUser").voice("media_id")

        expect(request.to_json).to eq({
          "touser" => "toUser",
          "msgtype" => "voice",
          "voice" => {"media_id"=>"media_id"}
        }.to_json)
      end

      specify "can convert video message" do
        request = Wechat::Message.to("toUser")
          .video("media_id", title: "title", description: "description")

        expect(request.to_json).to eq({
          "touser" => "toUser",
          "msgtype" => "video",
          "video" => {
            "media_id" => "media_id",
            "title" => "title",
            "description" => "description"
          }
        }.to_json)
      end

      specify "can convert music message" do
        request = Wechat::Message.to("toUser")
          .music("thumb_media_id", "music_url", title: "title", description: "description", :HQ_music_url=>"hq_music_url")

        expect(request.to_json).to eq({
          "touser" => "toUser",
          "msgtype" => "music",
          "music" => {
            "title" => "title",
            "description" => "description",
            "hqmusicurl" => "hq_music_url",
            "musicurl" => "music_url",
            "thumb_media_id" => "thumb_media_id"
          }
        }.to_json)
      end

      specify "can convert news message" do
        request = Wechat::Message.to("toUser")
          .news([{title: "title", description: "description", url: "url", pic_url: "pic_url"}])

        expect(request.to_json).to eq({
          "touser" => "toUser",
          "msgtype" => "news",
          "news" => {
            "articles" =>[
              {
                "title" => "title",
                "description" => "description",
                "picurl" => "pic_url",
                "url" => "url"
              }
            ]
          }
        }.to_json)
      end
    end

    describe "#save_to!" do
      specify "when given a model class, it will create a new model instance with json_hash and save it." do
        model_class = double("Model Class")
        model = double("Model Instance")

        message = Wechat::Message.to("toUser")
        expect(model_class).to receive(:new).with({
          to_user_name: "toUser",
          msg_type: "text",
          content: "text message",
          create_time: message[:CreateTime]
        }).and_return(model)
        expect(model).to receive(:save!).and_return(true)

        expect(message.text("text message").save_to!(model_class)).to eq(message)
      end
    end

  end

end
