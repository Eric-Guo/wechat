require 'spec_helper'

RSpec.describe Wechat::Api do
  let(:token_file) { Rails.root.join('tmp/access_token') }
  let(:jsapi_ticket_file) { Rails.root.join('tmp/jsapi_ticket') }

  subject do
    network_setting = Wechat::NetworkSetting.new(20, false, nil, nil, nil, nil)
    Wechat::Api.new('appid', 'secret', token_file, network_setting, jsapi_ticket_file)
  end

  before :each do
    allow(subject.access_token).to receive(:token).and_return('access_token')
    allow(subject.jsapi_ticket).to receive(:jsapi_ticket).and_return('jsapi_ticket')
  end

  describe '#API_BASE' do
    specify 'will get correct API_BASE' do
      expect(subject.client.base).to eq Wechat::Api::API_BASE
    end
  end

  describe '#draft_add' do
    let(:items) do
      [
        { thumb_media_id: 'THUMB_MEDIA_ID',
          title: 'TITLE', content: 'CONTENT', author: 'AUTHOR', content_source_url: 'CONTENT_SOURCE_URL',
          digest: 'DIGEST', need_open_comment: 0, only_fans_can_comment: 0 },
        { thumb_media_id: 'qI6_Ze_6PtV7svjolgs-rN6stStuHIjs9_DidOHaj0Q-mwvBelOXCFZiq2OsIU-p',
          title: 'Happy Day', content: 'content', author: 'xxx', content_source_url: 'www.qq.com',
          digest: 'digest', need_open_comment: 0 }
      ]
    end
    specify 'will post media/media_uploadnews with access_token and mpnews in json' do
      draft_news = {
        articles: [
          {
            thumb_media_id: 'THUMB_MEDIA_ID',
            title: 'TITLE',
            content: 'CONTENT',
            author: 'AUTHOR',
            content_source_url: 'CONTENT_SOURCE_URL',
            digest: 'DIGEST',
            need_open_comment: 0,
            only_fans_can_comment: 0
          },
          {
            thumb_media_id: 'qI6_Ze_6PtV7svjolgs-rN6stStuHIjs9_DidOHaj0Q-mwvBelOXCFZiq2OsIU-p',
            title: 'Happy Day',
            content: 'content',
            author: 'xxx',
            content_source_url: 'www.qq.com',
            digest: 'digest',
            need_open_comment: 0
          }
        ]
      }
      result = { media_id: 'MEDIA_ID' }
      expect(subject.client).to receive(:post).with('draft/add', draft_news.to_json, params: { access_token: 'access_token' }).and_return(result)
      expect(subject.draft_add(Wechat::Message.new(MsgType: 'draft_news').draft_news(items))).to eq(result)
    end
  end

  describe '#draft_count' do
    specify 'will get draft_count' do
      draft_count_result = { total_count: 1 }
      expect(subject.client).to receive(:get).with('draft/count', params: { access_token: 'access_token' }).and_return(draft_count_result)
      expect(subject.draft_count).to eq draft_count_result
    end
  end

  describe '#draft_batchget' do
    specify 'will get draft list with access_token' do
      draft_batchget_request = { offset: 0, count: 20, no_content: 0 }
      draft_batchget_result = { total_count: 1, item_count: 1,
                               item: [{ media_id: 'media_id',
                                content: {
                                  news_item: [
                                    {
                                      title: 'TITLE',
                                      author: 'AUTHOR',
                                      digest: 'DIGEST',
                                      content: 'CONTENT',
                                      content_source_url: 'CONTENT_SOURCE_URL',
                                      thumb_media_id: 'THUMB_MEDIA_ID',
                                      show_cover_pic: 0,
                                      need_open_comment: 0,
                                      only_fans_can_comment: 0,
                                      url: 'URL'
                                    },
                                    # 多图文消息会在此处有多篇文章
                                  ]
                                },
                                update_time: 12345 }] }
      expect(subject.client).to receive(:post)
        .with('draft/batchget', draft_batchget_request.to_json, params: { access_token: 'access_token' }).and_return(draft_batchget_result)
      expect(subject.draft_batchget(0, 20)).to eq draft_batchget_result
    end
  end
end
