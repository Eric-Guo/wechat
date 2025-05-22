require 'spec_helper'

RSpec.describe Wechat::Api do
  let(:token_file) { Rails.root.join('tmp/access_token') }
  let(:jsapi_ticket_file) { Rails.root.join('tmp/jsapi_ticket') }
  let(:appid) { 'appid' }
  let(:secret) { 'secret' }
  let(:network_setting) { Wechat::NetworkSetting.new(20, false, nil, nil, nil) }
  let(:api_config) { Wechat::ApiConfig.new(appid, secret, token_file, jsapi_ticket_file, network_setting) }

  subject do
    Wechat::Api.new(api_config)
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
      expect(subject.client).to receive(:post).with('draft/add', draft_news.to_json, hash_including(params: { access_token: 'access_token' })).and_return(result)
      expect(subject.draft_add(Wechat::Message.new(MsgType: 'draft_news').draft_news(items))).to eq(result)
    end
  end

  describe '#draft_get' do
    specify 'will post draft/get with access_token and media_id as payload at file based api endpoint as file' do
      news_item_result = {
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
          # 多图文消息应有多段 news_item 结构
        ]
      }

      expect(subject.client).to receive(:post)
        .with('draft/get', { media_id: 'media_id' }.to_json, hash_including(params: { access_token: 'access_token' })).and_return(news_item_result)
      expect(subject.draft_get('media_id')).to eq(news_item_result)
    end
  end

  describe '#draft_delete' do
    specify 'will post draft/delete with access_token and media_id in payload' do
      draft_delete_result = { errcode: 12321, errmsg: 'ERRMSG' }
      payload = { media_id: 'media_id' }
      expect(subject.client).to receive(:post)
        .with('draft/delete', payload.to_json,
              hash_including(params: { access_token: 'access_token' })).and_return(draft_delete_result)
      expect(subject.draft_delete('media_id')).to eq draft_delete_result
    end
  end

  describe '#draft_update' do
    specify 'will post draft/update' do
      draft_update_result = { errcode: 12322, errmsg: 'ERRMSG' }
      to_update_article = {
          title: 'TITLE',
          author: 'AUTHOR',
          digest: 'DIGEST',
          content: 'CONTENT',
          content_source_url: 'CONTENT_SOURCE_URL',
          thumb_media_id: 'THUMB_MEDIA_ID',
          need_open_comment: 0,
          only_fans_can_comment: 0
        }
      payload = {
        media_id: 'media_id',
        index: 1,
        articles: to_update_article
      }
      expect(subject.client).to receive(:post)
        .with('draft/update', payload.to_json,
              hash_including(params: { access_token: 'access_token' })).and_return(draft_update_result)
      expect(subject.draft_update('media_id', to_update_article, index: 1)).to eq draft_update_result
    end
  end

  describe '#draft_count' do
    specify 'will get draft_count' do
      draft_count_result = { total_count: 1 }
      expect(subject.client).to receive(:get).with('draft/count', hash_including(params: { access_token: 'access_token' })).and_return(draft_count_result)
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
        .with('draft/batchget', draft_batchget_request.to_json, hash_including(params: { access_token: 'access_token' })).and_return(draft_batchget_result)
      expect(subject.draft_batchget(0, 20)).to eq draft_batchget_result
    end
  end

  describe '#draft_switch' do
    specify 'will post draft/delete with access_token and media_id in payload' do
      draft_switch_result = { errcode: 123, errmsg: "ERRMSG", is_open: 1 }
      expect(subject.client).to receive(:post)
        .with('draft/switch', nil,
              hash_including(params: { access_token: 'access_token', checkonly: 1 })).and_return(draft_switch_result)
      expect(subject.draft_switch(checkonly: true)).to eq draft_switch_result
    end
  end
end
