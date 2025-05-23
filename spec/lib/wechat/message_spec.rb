require 'spec_helper'

RSpec.describe Wechat::Message do
  let(:text_request) { request_base.merge(MsgType: 'text', Content: 'text message') }

  let(:request_base) do
    {
      ToUserName: 'toUser',
      FromUserName: 'fromUser',
      CreateTime: '1348831860',
      MsgId: '1234567890123456'
    }
  end

  let(:response_base) do
    {
      ToUserName: 'sender',
      FromUserName: 'receiver',
      CreateTime: 1_348_831_860,
      MsgId: '1234567890123456'
    }
  end

  describe 'fromHash' do
    specify 'will create message' do
      message = Wechat::Message.from_hash(text_request)
      expect(message).to be_a(Wechat::Message)
      expect(message.message_hash.size).to eq(6)
    end
  end

  describe 'to' do
    let(:message) { Wechat::Message.from_hash(text_request) }
    specify 'will create base message' do
      reply = Wechat::Message.to('toUser')
      expect(reply).to be_a(Wechat::Message)
      expect(reply.message_hash).to include(ToUserName: 'toUser')
      expect(reply.message_hash[:CreateTime]).to be_a(Integer)
    end
  end

  describe 'to_party' do
    let(:message) { Wechat::Message.from_hash(text_request) }
    specify 'will create a message sent to a party' do
      reply = Wechat::Message.to_party(2)
      expect(reply).to be_a(Wechat::Message)
      expect(reply.message_hash).to include(ToPartyName: 2)
      expect(reply.message_hash[:CreateTime]).to be_a(Integer)
    end
  end

  describe 'to_mass' do
    let(:message) { Wechat::Message.from_hash(text_request) }
    specify 'will create base message' do
      reply = Wechat::Message.to_mass
      expect(reply).to be_a(Wechat::Message)
      expect(reply.message_hash).to include(filter: { is_to_all: true })
      expect(reply.message_hash[:send_ignore_reprint]).to eq 0
    end
  end

  describe '#reply' do
    let(:message) { Wechat::Message.from_hash(text_request) }
    specify 'will create base response message' do
      reply = message.reply
      expect(reply).to be_a(Wechat::Message)
      expect(reply.message_hash).to include(FromUserName: 'toUser', ToUserName: 'fromUser')
      expect(reply.message_hash[:CreateTime]).to be_a(Integer)
    end
  end

  describe 'parse message using as' do
    let(:image_request) { request_base.merge(MsgType: 'image', MediaId: 'media_id', PicUrl: 'pic_url') }
    let(:voice_request) { request_base.merge(MsgType: 'voice', MediaId: 'media_id', Format: 'format') }
    let(:video_request) { request_base.merge(MsgType: 'video', MediaId: 'media_id', ThumbMediaId: 'thumb_media_id') }
    let(:location_request) do
      request_base.merge(MsgType: 'location', Location_X: 'location_x', Location_Y: 'location_y',
                         Scale: 'scale', Label: 'label')
    end

    specify 'will raise error when parse message as an unknown type' do
      message = Wechat::Message.from_hash(text_request)
      expect { message.as(:unknown) }.to raise_error
    end

    specify 'will get text content' do
      message = Wechat::Message.from_hash(text_request)
      expect(message.as(:text)).to eq 'text message'
    end

    specify 'will get image file' do
      message = Wechat::Message.from_hash(image_request)
      expect(Wechat.api).to receive(:media).with('media_id')
      message.as(:image)
    end

    specify 'will get voice file' do
      message = Wechat::Message.from_hash(voice_request)
      expect(Wechat.api).to receive(:media).with('media_id')
      message.as(:voice)
    end

    specify 'will get video file' do
      message = Wechat::Message.from_hash(video_request)
      expect(Wechat.api).to receive(:media).with('media_id')
      message.as(:video)
    end

    specify 'will get location information' do
      message = Wechat::Message.from_hash(location_request)
      expect(message.as :location).to eq(location_x: 'location_x', location_y: 'location_y', scale: 'scale', label: 'label')
    end
  end

  context 'altering message fields' do
    let(:message) { Wechat::Message.from_hash(response_base) }
    describe '#to' do
      specify 'will update ToUserName field and return self' do
        expect(message.to('a user')).to eq(message)
        expect(message[:ToUserName]).to eq 'a user'
      end
    end

    describe '#text' do
      specify 'will update MsgType and Content field and return self' do
        expect(message.text('content')).to eq(message)
        expect(message[:MsgType]).to eq 'text'
        expect(message[:Content]).to eq 'content'
      end
    end

    describe '#textcard' do
      specify 'will update MsgType and TextCard field and return self' do
        expect(message.textcard('title', 'content', 'URL', '更多')).to eq(message)
        expect(message[:MsgType]).to eq 'textcard'
        expect(message[:TextCard]).to eq({btntxt: '更多', description: 'content', title: 'title', url: 'URL'})
      end

      specify 'btntxt can be omited' do
        expect(message.textcard('title', 'content', 'URL')).to eq(message)
        expect(message[:MsgType]).to eq 'textcard'
        expect(message[:TextCard]).to eq({description: 'content', title: 'title', url: 'URL'})
      end
    end

    describe '#markdown' do
      specify 'will update MsgType and Markdown field and return self' do
        expect(message.markdown('[这是一个链接](http://work.weixin.qq.com/api/doc)')).to eq(message)
        expect(message[:MsgType]).to eq 'markdown'
        expect(message[:Markdown]).to eq({content: '[这是一个链接](http://work.weixin.qq.com/api/doc)'})
      end
    end

    describe '#transfer_customer_service' do
      specify 'will update MsgType and return self' do
        expect(message.transfer_customer_service).to eq(message)
        expect(message[:MsgType]).to eq 'transfer_customer_service'
      end

      specify 'will update MsgType and KfAccount and return self' do
        expect(message.transfer_customer_service('kf_1')).to eq(message)
        expect(message[:MsgType]).to eq 'transfer_customer_service'
        expect(message[:TransInfo][:KfAccount]).to eq 'kf_1'
      end
    end

    describe '#image' do
      specify 'will update MsgType and MediaId field and return self' do
        expect(message.image('media_id')).to eq(message)
        expect(message[:MsgType]).to eq 'image'
        expect(message[:Image][:MediaId]).to eq 'media_id'
      end
    end

    describe '#voice' do
      specify 'will update MsgType and MediaId field and return self' do
        expect(message.voice('media_id')).to eq(message)

        expect(message[:MsgType]).to eq 'voice'
        expect(message[:Voice][:MediaId]).to eq 'media_id'
      end
    end

    describe '#video' do
      specify 'will update MsgType and MediaId, Title, Description field and return self' do
        expect(message.video('media_id', title: 'title', description: 'description')).to eq(message)

        expect(message[:MsgType]).to eq 'video'
        expect(message[:Video][:MediaId]).to eq 'media_id'
        expect(message[:Video][:Title]).to eq 'title'
        expect(message[:Video][:Description]).to eq 'description'
      end
    end

    describe '#music' do
      specify 'will update MsgType and ThumbMediaId, Title, Description field and return self' do
        expect(message.music('thumb_media_id', 'music_url', title: 'title', description: 'description', HQ_music_url: 'hq_music_url')).to eq(message)

        expect(message[:MsgType]).to eq 'music'
        expect(message[:Music][:Title]).to eq 'title'
        expect(message[:Music][:Description]).to eq 'description'
        expect(message[:Music][:MusicUrl]).to eq 'music_url'
        expect(message[:Music][:HQMusicUrl]).to eq 'hq_music_url'
        expect(message[:Music][:ThumbMediaId]).to eq 'thumb_media_id'
      end
    end

    describe '#news' do
      let(:items) do
        [
          { title: 'title', description: 'description', url: 'url', pic_url: 'pic_url' },
          { title: 'title', description: 'description', url: nil, pic_url: 'pic_url' }
        ]
      end

      after :each do
        expect(message[:MsgType]).to eq('news')
        expect(message[:ArticleCount]).to eq(2)
        expect(message[:Articles][0][:Title]).to eq 'title'
        expect(message[:Articles][0][:Description]).to eq 'description'
        expect(message[:Articles][0][:Url]).to eq 'url'
        expect(message[:Articles][0][:PicUrl]).to eq 'pic_url'
        expect(message[:Articles][1].key?(:Url)).to eq false
      end

      specify 'when no block is given, whill take the items argument as an array articles hash' do
        message.news(items)
      end

      specify 'will update MesageType, ArticleCount, Articles field and return self' do
        message.news(items) { |articles, item| articles.item(**item) }
      end
    end

    describe '#mpnews' do
      let(:items) do
        [
          { thumb_media_id: 'qI6_Ze_6PtV7svjolgs-rN6stStuHIjs9_DidOHaj0Q-mwvBelOXCFZiq2OsIU-p',
            author: 'xxx', title: 'Happy Day', content_source_url: 'www.qq.com',
            content: 'content', digest: 'digest', show_cover_pic: 1 },
          { thumb_media_id: 'qI6_Ze_6PtV7svjolgs-rN6stStuHIjs9_DidOHaj0Q-mwvBelOXCFZiq2OsIU-p',
            author: 'xxx', title: 'Happy Day', content_source_url: 'www.qq.com',
            content: 'content', digest: 'digest', show_cover_pic: 0 }
        ]
      end

      after :each do
        expect(message[:MsgType]).to eq('mpnews')
        expect(message[:Articles][0][:Title]).to eq 'Happy Day'
        expect(message[:Articles][0][:Content]).to eq 'content'
        expect(message[:Articles][0][:ContentSourceUrl]).to eq 'www.qq.com'
        expect(message[:Articles][0][:ShowCoverPic]).to eq 1
        expect(message[:Articles][1].key?(:ShowCoverPic)).to eq true
      end

      specify 'when no block is given, whill take the items argument as an array articles hash' do
        message.mpnews(items)
      end

      specify 'will update MesageType, ArticleCount, Articles field and return self' do
        message.mpnews(items) { |articles, item| articles.item(**item) }
      end
    end

    describe '#to_xml' do
      let(:response) { Wechat::Message.from_hash(response_base) }

      specify 'root is xml tag' do
        hash = Hash.from_xml(response.text('text content').to_xml)
        expect(hash.keys).to eq(['xml'])
      end

      specify 'collection key is item' do
        xml = response.news([
          { title: 'title1', description: 'description', url: 'url', pic_url: 'pic_url' },
          { title: 'title2', description: 'description', url: 'url', pic_url: 'pic_url' }
        ]).to_xml

        hash = Hash.from_xml(xml)
        expect(hash['xml']['Articles']['item']).to be_a(Array)
        expect(hash['xml']['Articles']['item'].size).to eq 2
      end
    end

    describe '#to_json' do
      specify 'can convert text message' do
        request = Wechat::Message.to('toUser').text('text content')
        expect(request.to_json).to eq({
          touser: 'toUser',
          msgtype: 'text',
          text: { content: 'text content' }
        }.to_json)
      end

      specify 'can convert image message' do
        request = Wechat::Message.to('toUser').image('image_media_id')
        expect(request.to_json).to eq({
          touser: 'toUser',
          msgtype: 'image',
          image: { media_id: 'image_media_id' }
        }.to_json)
      end

      specify 'can convert voice message' do
        request = Wechat::Message.to('toUser').voice('voice_media_id')

        expect(request.to_json).to eq({
          touser: 'toUser',
          msgtype: 'voice',
          voice: { media_id: 'voice_media_id' }
        }.to_json)
      end

      specify 'can convert video message' do
        request = Wechat::Message.to('toUser').video('video_media_id', title: 'title', description: 'description')

        expect(request.to_json).to eq({
          touser: 'toUser',
          msgtype: 'video',
          video: {
            media_id: 'video_media_id',
            title: 'title',
            description: 'description'
          }
        }.to_json)
      end

      specify 'can convert file message' do
        request = Wechat::Message.to('toUser').file('file_media_id')

        expect(request.to_json).to eq({
          touser: 'toUser',
          msgtype: 'file',
          file: {
            media_id: 'file_media_id'
          }
        }.to_json)
      end

      specify 'can convert music message' do
        request = Wechat::Message.to('toUser')
                                 .music('thumb_media_id', 'music_url', title: 'title', description: 'description', HQ_music_url: 'hq_music_url')

        expect(request.to_json).to eq({
          touser: 'toUser',
          msgtype: 'music',
          music: {
            title: 'title',
            description: 'description',
            hqmusicurl: 'hq_music_url',
            musicurl: 'music_url',
            thumb_media_id: 'thumb_media_id'
          }
        }.to_json)
      end

      specify 'can convert news message' do
        request = Wechat::Message.to('toUser')
                                 .news([{ title: 'title', description: 'description', url: 'url', pic_url: 'pic_url' }])

        expect(request.to_json).to eq({
          touser: 'toUser',
          msgtype: 'news',
          news: {
            articles: [
              {
                title: 'title',
                description: 'description',
                picurl: 'pic_url',
                url: 'url'
              }
            ]
          }
        }.to_json)
      end

      specify 'can convert to mass text message' do
        request = Wechat::Message.to_mass(tag_id: 1).text('mass text content')

        expect(JSON.parse(request.to_json)).to eq(JSON.parse({
          filter: { is_to_all: false, tag_id: 1 },
          send_ignore_reprint: 0,
          msgtype: 'text',
          text: { content: 'mass text content' }
        }.to_json))
      end

      specify 'can convert to mass mpnews message' do
        request = Wechat::Message.to_mass(send_ignore_reprint: 1).ref_mpnews('mpnews_media_id')

        expect(JSON.parse(request.to_json)).to eq(JSON.parse({
          filter: { is_to_all: true },
          send_ignore_reprint: 1,
          msgtype: 'mpnews',
          mpnews: { media_id: 'mpnews_media_id' }
        }.to_json))
      end

      specify 'can convert template message' do
        request = Wechat::Message.to('toUser').template(template_id: 'template_id',
                                                        url: 'http://weixin.qq.com/download',
                                                        data: {
                                                          first: { value: '恭喜你购买成功！' },
                                                          orderProductName: { value: '巧克力' },
                                                          orderMoneySum: { value: '39.8 元' },
                                                          Remark: { value: '欢迎再次购买！' }
                                                        })

        expect(request.to_json).to eq({
          touser: 'toUser',
          template_id: 'template_id',
          url: 'http://weixin.qq.com/download',
          data: {
            first: { value: '恭喜你购买成功！' },
            orderProductName: { value: '巧克力' },
            orderMoneySum: { value: '39.8 元' },
            Remark: { value: '欢迎再次购买！' }
          }
        }.to_json)
      end

      specify 'can convert template message with miniprogram' do
        request = Wechat::Message.to('toUser').template(template_id: 'template_id',
                                                        miniprogram: {
                                                            appid: 'wxabcdefg',
                                                            pagepath: 'index'
                                                        },
                                                        data: {
                                                            first: { value: '恭喜你购买成功！' },
                                                            orderProductName: { value: '巧克力' },
                                                            orderMoneySum: { value: '39.8 元' },
                                                            Remark: { value: '欢迎再次购买！' }
                                                        })


        expect(request.to_json).to eq({touser: 'toUser',
                                       template_id: 'template_id',
                                       miniprogram: {
                                           appid: 'wxabcdefg',
                                           pagepath: 'index'
                                       },
                                       data: {
                                           first: { value: '恭喜你购买成功！' },
                                           orderProductName: { value: '巧克力' },
                                           orderMoneySum: { value: '39.8 元' },
                                           Remark: { value: '欢迎再次购买！' }
                                       }}.to_json)
      end
    end

    describe '#save_to!' do
      specify 'when given a model class, it will create a new model instance with json_hash and save it.' do
        model_class = double('Model Class')
        model = double('Model Instance')

        message = Wechat::Message.to('toUser')
        expect(model_class).to receive(:new)
          .with(hash_including(to_user_name: 'toUser',
                msg_type: 'text',
                content: 'text message',
                create_time: message[:CreateTime])).and_return(model)
        expect(model).to receive(:save!).and_return(true)

        expect(message.text('text message').send(:save_to!, model_class)).to eq(message)
      end
    end
  end
end
