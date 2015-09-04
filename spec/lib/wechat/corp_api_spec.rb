require 'spec_helper'

RSpec.describe Wechat::CorpApi do
  let(:toke_file) { Rails.root.join('tmp/access_token') }

  subject do
    Wechat::CorpApi.new('corpid', 'corpsecret', toke_file, '1', false)
  end

  before :each do
    allow(subject.access_token).to receive(:token).and_return('access_token')
  end

  describe '#user' do
    specify 'will get user/get with access_token and userid' do
      userid = 'userid'
      user_result = { errcode: 0, errmsg: 'ok',
                      userid: 'zhangsan',
                      name: '李四',
                      department: [1, 2],
                      position: '后台工程师',
                      mobile: '15913215421',
                      gender: '1',
                      email: 'zhangsan@gzdev.com',
                      weixinid: 'lisifordev',
                      avatar: 'http://wx.qlogo.cn/mmopen/ajNVdqHZLLA3WJ6DSZUfiakYe37PKnQhBIeOQBO4czqrnZDS79FH5Wm5m4X69TBicnHFlhiafvDwklOpZeXYQQ2icg/0',
                      status: 1,
                      extattr: { attrs: [{ name: '爱好', value: '旅游' }, { name: '卡号', value: '1234567234' }] } }
      expect(subject.client).to receive(:get)
        .with('user/get', params: { userid: userid, access_token: 'access_token' }).and_return(user_result)
      expect(subject.user(userid)).to eq user_result
    end
  end

  describe '#invite_user' do
    specify 'will get invite/send with access_token and json userid' do
      userid = 'userid'
      invite_request = { userid: userid }
      invite_result = { errcode: 0, errmsg: 'ok', type: 1 }
      expect(subject.client).to receive(:post)
        .with('invite/send', invite_request.to_json, params: { access_token: 'access_token' }).and_return(invite_result)
      expect(subject.invite_user(userid)).to eq invite_result
    end
  end

  describe '#user_auth_success' do
    specify 'will get user/authsucc with access_token and userid' do
      userid = 'userid'
      user_auth_result = { errcode: 0, errmsg: 'ok' }
      expect(subject.client).to receive(:get)
        .with('user/authsucc', params: { userid: userid, access_token: 'access_token' }).and_return(user_auth_result)
      expect(subject.user_auth_success(userid)).to eq user_auth_result
    end
  end

  describe '#user_delete' do
    specify 'will get user/delete with access_token and userid' do
      userid = 'userid'
      user_delete_result = { errcode: 0, errmsg: 'deleted' }
      expect(subject.client).to receive(:get)
        .with('user/delete', params: { userid: userid, access_token: 'access_token' }).and_return(user_delete_result)
      expect(subject.user_delete(userid)).to eq user_delete_result
    end
  end

  describe '#department' do
    specify 'will get user/get with access_token and userid' do
      departmentid = 'departmentid'
      department_result = { errcode: 0, errmsg: 'ok',
                            department: [
                              { id: 2,
                                name: '广州研发中心',
                                parentid: 1,
                                order: 10 },
                              { id: 3,
                                name: '邮箱产品部',
                                parentid: 2,
                                order: 40 }] }
      expect(subject.client).to receive(:get)
        .with('department/list', params: { id: departmentid, access_token: 'access_token' }).and_return(department_result)
      expect(subject.department(departmentid)).to eq department_result
    end
  end

  describe '#message_send' do
    specify 'will post message with access_token, and json payload' do
      payload = {
        touser: 'openid',
        msgtype: 'text',
        agentid: '1',
        text: { content: 'message content' }
      }

      expect(subject.client).to receive(:post)
        .with('message/send', payload.to_json,
              content_type: :json, params: { access_token: 'access_token' }).and_return(true)

      expect(subject.message_send 'openid', 'message content').to be true
    end
  end
end
