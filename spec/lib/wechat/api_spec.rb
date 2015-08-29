require 'spec_helper'

RSpec.describe Wechat::Api do
  let(:toke_file) { Rails.root.join('tmp/access_token') }
  let(:jsapi_ticket_file) { Rails.root.join('tmp/jsapi_ticket') }

  subject do
    Wechat::Api.new('appid', 'secret', toke_file, jsapi_ticket_file)
  end

  before :each do
    allow(subject.access_token).to receive(:token).and_return('access_token')
    allow(subject.jsapi_ticket).to receive(:jsapi_ticket).and_return('jsapi_ticket')
  end

  describe '#groups' do
    specify 'will get groups with access_token' do
      groups_result = 'groups_result'
      expect(subject.client).to receive(:get).with('groups/get', params: { access_token: 'access_token' }).and_return(groups_result)
      expect(subject.groups).to eq groups_result
    end
  end

  describe '#group_create' do
    specify 'will post groups/create with access_token and new group json_data' do
      new_group = { group: { name: 'new_group_name' } }
      expect(subject.client).to receive(:post).with('groups/create', new_group.to_json, params: { access_token: 'access_token' }).and_return(true)
      expect(subject.group_create('new_group_name')).to be true
    end
  end

  describe '#group_update' do
    specify 'will post groups/update with access_token and json_data' do
      update_group = { group: { id: 108, name: 'test2_modify2' } }
      expect(subject.client).to receive(:post).with('groups/update', update_group.to_json, params: { access_token: 'access_token' }).and_return(true)
      expect(subject.group_update(108, 'test2_modify2')).to be true
    end
  end

  describe '#group_delete' do
    specify 'will post groups/delete with access_token' do
      delete_group = { group: { id: 108 } }
      expect(subject.client).to receive(:post).with('groups/delete', delete_group.to_json, params: { access_token: 'access_token' }).and_return(true)
      expect(subject.group_delete(108)).to be true
    end
  end

  describe '#users' do
    specify 'will get user/get with access_token' do
      users_result = 'users_result'
      expect(subject.client).to receive(:get).with('user/get', params: { access_token: 'access_token' }).and_return(users_result)
      expect(subject.users).to eq(users_result)
    end

    specify 'will get user/get with access_token and next_openid' do
      users_result = 'users_result'
      expect(subject.client).to receive(:get)
        .with('user/get', params: { access_token: 'access_token',
                                    next_openid: 'next_openid' }).and_return(users_result)
      expect(subject.users('next_openid')).to eq(users_result)
    end
  end

  describe '#user' do
    specify 'will get user/info with access_token and openid' do
      user_result = 'user_result'
      expect(subject.client).to receive(:get).with('user/info', params: { access_token: 'access_token', openid: 'openid' }).and_return(user_result)
      expect(subject.user 'openid').to eq(user_result)
    end
  end

  describe '#user_group' do
    specify 'will post groups/getid with access_token and openid to get user groups info' do
      user_request = { openid: 'openid' }
      user_response = { groupid: 102 }
      expect(subject.client).to receive(:post)
        .with('groups/getid', user_request.to_json, params: { access_token: 'access_token' }).and_return(user_response)
      expect(subject.user_group 'openid').to eq(user_response)
    end
  end

  describe '#user_change_group' do
    specify 'will post groups/getid with access_token and openid to get user groups info' do
      user_request = { openid: 'openid', to_groupid: 108 }
      expect(subject.client).to receive(:post)
        .with('groups/members/update', user_request.to_json, params: { access_token: 'access_token' }).and_return(true)
      expect(subject.user_change_group 'openid', 108).to be true
    end
  end

  describe '#menu' do
    specify 'will get menu/get with access_token' do
      menu_result = 'menu_result'
      expect(subject.client).to receive(:get).with('menu/get', params: { access_token: 'access_token' }).and_return(menu_result)
      expect(subject.menu).to eq(menu_result)
    end
  end

  describe '#menu_delete' do
    specify 'will get menu/delete with access_token' do
      expect(subject.client).to receive(:get).with('menu/delete', params: { access_token: 'access_token' }).and_return(true)
      expect(subject.menu_delete).to be true
    end
  end

  describe '#menu_create' do
    specify 'will post menu/create with access_token and json_data' do
      menu = { buttons: ['a_button'] }
      expect(subject.client).to receive(:post).with('menu/create', menu.to_json, params: { access_token: 'access_token' }).and_return(true)
      expect(subject.menu_create(menu)).to be true
    end
  end

  describe '#media' do
    specify 'will get media/get with access_token and media_id at file based api endpoint as file' do
      media_result = 'media_result'

      expect(subject.client).to receive(:get)
        .with('media/get', params: { access_token: 'access_token', media_id: 'media_id' },
                           base: 'http://file.api.weixin.qq.com/cgi-bin/',
                           as: :file).and_return(media_result)
      expect(subject.media('media_id')).to eq(media_result)
    end
  end

  describe '#media_create' do
    specify 'will post media/upload with access_token, type and media payload at file based api endpoint' do
      file = 'file'
      expect(subject.client).to receive(:post)
        .with('media/upload', { upload: { media: file } },
              params: { type: 'image', access_token: 'access_token' },
              base: 'http://file.api.weixin.qq.com/cgi-bin/').and_return(true)
      expect(subject.media_create('image', file)).to be true
    end
  end

  describe '#custom_message_send' do
    specify 'will post message/custom/send with access_token, and json payload' do
      payload = {
        touser: 'openid',
        msgtype: 'text',
        text: { content: 'message content' }
      }

      expect(subject.client).to receive(:post)
        .with('message/custom/send', payload.to_json,
              params: { access_token: 'access_token' }, content_type: :json).and_return(true)

      expect(subject.custom_message_send Wechat::Message.to('openid').text('message content')).to be true
    end
  end
end
