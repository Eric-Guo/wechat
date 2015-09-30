require 'spec_helper'

RSpec.describe Wechat::CorpApi do
  let(:toke_file) { Rails.root.join('tmp/access_token') }

  subject do
    Wechat::CorpApi.new('corpid', 'corpsecret', toke_file, '1', false)
  end

  before :each do
    allow(subject.access_token).to receive(:token).and_return('access_token')
  end

  describe '#API_BASE' do
    specify 'will get correct API_BASE' do
      expect(subject.client.base).to eq Wechat::CorpApi::API_BASE
    end
  end

  describe '#agent_list' do
    specify 'will get user/get with access_token and userid' do
      agent_list_result = { errcode: 0, errmsg: 'ok',
                            agentlist: [{ agentid: '5', name: '企业小助手',
                                          square_logo_url: 'url', round_logo_url: 'url' },
                                        { agentid: '8', name: 'HR小助手',
                                          square_logo_url: 'url', round_logo_url: 'url' }] }
      expect(subject.client).to receive(:get)
        .with('agent/list', params: { access_token: 'access_token' }).and_return(agent_list_result)
      expect(subject.agent_list).to eq agent_list_result
    end
  end

  describe '#agent' do
    specify 'will get user/get with access_token and userid' do
      agentid = '1'
      agent_result = { errcode: 0, errmsg: 'ok', agentid: '1',
                       name: 'NAME', square_logo_url: 'xxxxxxxx', round_logo_url: 'yyyyyyyy', description: 'desc',
                       allow_userinfos: { user: [{ userid: 'id1', status: 1 },
                                                 { userid: 'id2', status: 1 }] },
                       allow_partys: { partyid: [1] },
                       allow_tags: { tagid: [1, 2, 3] },
                       close: 0, redirect_domain: 'www.qq.com', report_location_flag: 0,
                       isreportuser: 0, isreportenter: 0 }
      expect(subject.client).to receive(:get)
        .with('agent/get', params: { agentid: agentid, access_token: 'access_token' }).and_return(agent_result)
      expect(subject.agent(agentid)).to eq agent_result
    end
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

  describe '#user_batchdelete' do
    specify 'will get user/delete with access_token and userid' do
      batchdelete_request = { useridlist: %w(6749 6110) }
      user_delete_result = { errcode: 0, errmsg: 'deleted' }
      expect(subject.client).to receive(:post)
        .with('user/batchdelete', batchdelete_request.to_json, params: { access_token: 'access_token' }).and_return(user_delete_result)
      expect(subject.user_batchdelete(%w(6749 6110))).to eq user_delete_result
    end
  end

  describe '#batch_job_result' do
    specify 'will get batch/getresult with access_token and userid' do
      batch_result = { errcode: 0, errmsg: 'ok', status: 1,
                       type: 'replace_user', total: 3, percentage: 33, remaintime: 1,
                       result: [{}, {}] }
      expect(subject.client).to receive(:get)
        .with('batch/getresult', params: { jobid: 'jobid', access_token: 'access_token' }).and_return(batch_result)
      expect(subject.batch_job_result('jobid')).to eq batch_result
    end
  end

  describe '#batch_replaceparty' do
    specify 'will post batch/replaceparty with access_token and new department payload' do
      batch_replaceparty_request = { media_id: 'media_id' }
      batch_replaceparty_result = { errcode: 0, errmsg: 'ok', jobid: 'jobid' }
      expect(subject.client).to receive(:post)
        .with('batch/replaceparty', batch_replaceparty_request.to_json, params: { access_token: 'access_token' }).and_return(batch_replaceparty_result)
      expect(subject.batch_replaceparty('media_id')).to eq batch_replaceparty_result
    end
  end

  describe '#batch_replaceuser' do
    specify 'will post batch/replaceuser with access_token and new department payload' do
      batch_replaceuser_request = { media_id: 'media_id' }
      batch_replaceuser_result = { errcode: 0, errmsg: 'ok', jobid: 'jobid' }
      expect(subject.client).to receive(:post)
        .with('batch/replaceuser', batch_replaceuser_request.to_json, params: { access_token: 'access_token' }).and_return(batch_replaceuser_result)
      expect(subject.batch_replaceuser('media_id')).to eq batch_replaceuser_result
    end
  end

  describe '#batch_syncuser' do
    specify 'will post batch/syncuser with access_token and new department payload' do
      batch_syncuser_request = { media_id: 'media_id' }
      batch_syncuser_result = { errcode: 0, errmsg: 'ok', jobid: 'jobid' }
      expect(subject.client).to receive(:post)
        .with('batch/syncuser', batch_syncuser_request.to_json, params: { access_token: 'access_token' }).and_return(batch_syncuser_result)
      expect(subject.batch_syncuser('media_id')).to eq batch_syncuser_result
    end
  end

  describe '#department_create' do
    specify 'will post department/create with access_token and new department payload' do
      department_create_request = { name: '广州研发中心', parentid: '1' }
      department_create_result = { errcode: 0, errmsg: 'created', id: 2 }
      expect(subject.client).to receive(:post)
        .with('department/create', department_create_request.to_json, params: { access_token: 'access_token' }).and_return(department_create_result)
      expect(subject.department_create('广州研发中心', '1')).to eq department_create_result
    end
  end

  describe '#department_delete' do
    specify 'will get department/delete with access_token and id' do
      departmentid = 'departmentid'
      department_delete_result = { errcode: 0, errmsg: 'deleted' }
      expect(subject.client).to receive(:get)
        .with('department/delete', params: { access_token: 'access_token', id: departmentid }).and_return(department_delete_result)
      expect(subject.department_delete('departmentid')).to eq department_delete_result
    end
  end

  describe '#department_update' do
    specify 'will post department/update with access_token and id' do
      departmentid = 'departmentid'
      department_update_request = { id: departmentid, name: '广研' }
      department_update_result = { errcode: 0, errmsg: 'updated' }
      expect(subject.client).to receive(:post)
        .with('department/update', department_update_request.to_json, params: { access_token: 'access_token' }).and_return(department_update_result)
      expect(subject.department_update('departmentid', '广研')).to eq department_update_result
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

  describe '#user_simplelist' do
    specify 'will get user/simplelist with access_token and departmentid' do
      departmentid = 'departmentid'
      simplelist_result = { errcode: 0, errmsg: 'ok',
                            userlist: [{ userid: 'zhangsan', name: '李四', department: [1, 2] }] }
      expect(subject.client).to receive(:get)
        .with('user/simplelist', params: { departmentid: departmentid, fetch_child: 0, status: 0, access_token: 'access_token' }).and_return(simplelist_result)
      expect(subject.user_simplelist(departmentid)).to eq simplelist_result
    end
  end

  describe '#user_list' do
    specify 'will get user/list with access_token and departmentid' do
      user_list_result = { errcode: 0, errmsg: 'ok',
                           userlist:  [{ userid: 'zhangsan',
                                         name: '李四',
                                         department: [1, 2],
                                         position: '后台工程师',
                                         mobile: '15913215421',
                                         gender: '1',
                                         email: 'zhangsan@gzdev.com',
                                         weixinid: 'lisifordev',
                                         avatar:           'http://wx.qlogo.cn/mmopen/ajNVdqHZLLA3WJ6DSZUfiakYe37PKnQhBIeOQBO4czqrnZDS79FH5Wm5m4X69TBicnHFlhiafvDwklOpZeXYQQ2icg/0',
                                         status: 1,
                                         extattr: { attrs: [{ name: '爱好', value: '旅游' }, { name: '卡号', value: '1234567234' }] } }] }
      expect(subject.client).to receive(:get)
        .with('user/list', params: { departmentid: 1, fetch_child: 0, status: 0, access_token: 'access_token' }).and_return(user_list_result)
      expect(subject.user_list(1)).to eq user_list_result
    end
  end

  describe '#tag_create' do
    specify 'will post tag/create with access_token and new department payload' do
      tag_create_request = { tagname: 'UI', tagid: 1 }
      tag_create_result = { errcode: 0, errmsg: 'created', tagid: 1 }
      expect(subject.client).to receive(:post)
        .with('tag/create', tag_create_request.to_json, params: { access_token: 'access_token' }).and_return(tag_create_result)
      expect(subject.tag_create('UI', 1)).to eq tag_create_result
    end
  end

  describe '#tag_update' do
    specify 'will post tag/update with access_token and new department payload' do
      tag_update_request = { tagid: 1, tagname: 'UI Design' }
      tag_update_result = { errcode: 0, errmsg: 'updated' }
      expect(subject.client).to receive(:post)
        .with('tag/update', tag_update_request.to_json, params: { access_token: 'access_token' }).and_return(tag_update_result)
      expect(subject.tag_update(1, 'UI Design')).to eq tag_update_result
    end
  end

  describe '#tag_delete' do
    specify 'will get tag/delete with access_token and tagid' do
      tag_delete_result = { errcode: 0, errmsg: 'deleted' }
      expect(subject.client).to receive(:get)
        .with('tag/delete', params: { tagid: 1, access_token: 'access_token' }).and_return(tag_delete_result)
      expect(subject.tag_delete(1)).to eq tag_delete_result
    end
  end

  describe '#tags' do
    specify 'will get tag/list with access_token' do
      tags_result = { errcode: 0, errmsg: 'ok',
                      taglist: [{ tagid: 1, tagname: 'a' },
                                { tagid: 2, tagname: 'b' }] }
      expect(subject.client).to receive(:get)
        .with('tag/list', params: { access_token: 'access_token' }).and_return(tags_result)
      expect(subject.tags).to eq tags_result
    end
  end

  describe '#tag' do
    specify 'will get user/get with access_token and tagid' do
      tag_result = { errcode: 0, errmsg: 'ok',
                     userlist: [{ userid: 'zhangsan', name: '李四' }],
                     partylist: [2] }
      expect(subject.client).to receive(:get)
        .with('tag/get', params: { tagid: 1, access_token: 'access_token' }).and_return(tag_result)
      expect(subject.tag(1)).to eq tag_result
    end
  end

  describe '#tag_add_user' do
    specify 'will post tag/addtagusers with tagid, userlist(userids) and access_token' do
      tag_add_user_request = { tagid: 1, userlist: %w(6749 6110), partylist: nil }
      tag_add_user_result = { errcode: 0, errmsg: 'ok' }
      expect(subject.client).to receive(:post)
        .with('tag/addtagusers', tag_add_user_request.to_json, params: { access_token: 'access_token' }).and_return(tag_add_user_result)
      expect(subject.tag_add_user(1, %w(6749 6110))).to eq tag_add_user_result
    end

    specify 'will post tag/addtagusers with tagid, partylist(departmentids) and access_token' do
      tag_add_party_request = { tagid: 1, userlist: nil, partylist: [1, 2] }
      tag_add_party_result = { errcode: 0, errmsg: 'ok' }
      expect(subject.client).to receive(:post)
        .with('tag/addtagusers', tag_add_party_request.to_json, params: { access_token: 'access_token' }).and_return(tag_add_party_result)
      expect(subject.tag_add_user(1, nil, [1, 2])).to eq tag_add_party_result
    end
  end

  describe '#tag_del_user' do
    specify 'will post tag/deltagusers with tagid, userlist(userids) and access_token' do
      tag_del_user_request = { tagid: 1, userlist: %w(6749 6110), partylist: nil }
      tag_del_user_result = { errcode: 0, errmsg: 'deleted' }
      expect(subject.client).to receive(:post)
        .with('tag/deltagusers', tag_del_user_request.to_json, params: { access_token: 'access_token' }).and_return(tag_del_user_result)
      expect(subject.tag_del_user(1, %w(6749 6110))).to eq tag_del_user_result
    end

    specify 'will post tag/deltagusers with tagid, partylist(departmentids) and access_token' do
      tag_del_party_request = { tagid: 1, userlist: nil, partylist: [1, 2] }
      tag_del_party_result = { errcode: 0, errmsg: 'deleted' }
      expect(subject.client).to receive(:post)
        .with('tag/deltagusers', tag_del_party_request.to_json, params: { access_token: 'access_token' }).and_return(tag_del_party_result)
      expect(subject.tag_del_user(1, nil, [1, 2])).to eq tag_del_party_result
    end
  end

  describe '#menu' do
    specify 'will get menu/get with access_token and agentid' do
      menu_result = 'menu_result'
      expect(subject.client).to receive(:get).with('menu/get', params: { access_token: 'access_token', agentid: '1' }).and_return(menu_result)
      expect(subject.menu).to eq(menu_result)
    end
  end

  describe '#menu_delete' do
    specify 'will get menu/delete with access_token and agentid' do
      expect(subject.client).to receive(:get).with('menu/delete', params: { access_token: 'access_token', agentid: '1' }).and_return(true)
      expect(subject.menu_delete).to be true
    end
  end

  describe '#menu_create' do
    specify 'will post menu/create with access_token, agentid and json_data' do
      menu = { buttons: ['a_button'] }
      expect(subject.client).to receive(:post)
        .with('menu/create', menu.to_json, params: { access_token: 'access_token', agentid: '1' }).and_return(true)
      expect(subject.menu_create(menu)).to be true
    end
  end

  describe '#media' do
    specify 'will get media/get with access_token and media_id at file based api endpoint as file' do
      media_result = 'media_result'

      expect(subject.client).to receive(:get)
        .with('media/get', params: { access_token: 'access_token', media_id: 'media_id' },
                           as: :file).and_return(media_result)
      expect(subject.media('media_id')).to eq(media_result)
    end
  end

  describe '#media_create' do
    specify 'will post media/upload with access_token, type and media payload at file based api endpoint' do
      file = 'file'
      expect(subject.client).to receive(:post)
        .with('media/upload', { upload: { media: file } },
              params: { type: 'image', access_token: 'access_token' }).and_return(true)
      expect(subject.media_create('image', file)).to be true
    end
  end

  describe '#material' do
    specify 'will get material/get with access_token, media_id and agentid at file based api endpoint as file' do
      material_result = 'material_result'

      expect(subject.client).to receive(:get)
        .with('material/get', params: { access_token: 'access_token', media_id: 'media_id', agentid: '1' },
                              as: :file).and_return(material_result)
      expect(subject.material('media_id')).to eq(material_result)
    end
  end

  describe '#material_count' do
    specify 'will get material_count with access_token' do
      material_count_result = { errcode: 0, errmsg: 'ok',
                                total_count: 37,
                                image_count: 12,
                                voice_count: 10,
                                video_count: 3,
                                file_count: 3,
                                mpnews_count: 6 }
      expect(subject.client).to receive(:get)
        .with('material/get_count', params: { access_token: 'access_token', agentid: '1' }).and_return(material_count_result)
      expect(subject.material_count).to eq material_count_result
    end
  end

  describe '#material_list' do
    specify 'will get material list with access_token' do
      material_list_request = { type: 'image', agentid: '1', offset: 0, count: 50 }
      material_list_result = { total_count: 1, item_count: 1,
                               item: [{ media_id: 'media_id', name: 'name', update_time: 12345, url: 'url' }] }
      expect(subject.client).to receive(:post)
        .with('material/batchget', material_list_request.to_json, params: { access_token: 'access_token' }).and_return(material_list_result)
      expect(subject.material_list('image', 0, 50)).to eq material_list_result
    end
  end

  describe '#material_add' do
    specify 'will post material/add_material with access_token, type and media payload at file based api endpoint' do
      file = 'file'
      expect(subject.client).to receive(:post)
        .with('material/add_material', { upload: { media: file } },
              params: { type: 'image', access_token: 'access_token', agentid: '1' }).and_return(true)
      expect(subject.material_add('image', file)).to be true
    end
  end

  describe '#material_delete' do
    specify 'will post material/del_material with access_token and media_id' do
      media_id = 'media_id'
      material_delete_result = { errcode: 0, errmsg: 'deleted' }
      expect(subject.client).to receive(:get)
        .with('material/del', params: { media_id: media_id, access_token: 'access_token', agentid: '1' }).and_return(material_delete_result)
      expect(subject.material_delete(media_id)).to eq material_delete_result
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
