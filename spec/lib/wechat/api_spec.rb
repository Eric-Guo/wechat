require 'spec_helper'

RSpec.describe Wechat::Api do
  let(:token_file) { Rails.root.join('tmp/access_token') }
  let(:jsapi_ticket_file) { Rails.root.join('tmp/jsapi_ticket') }

  subject do
    Wechat::Api.new('appid', 'secret', token_file, 20, false, jsapi_ticket_file)
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

  describe '#callbackip' do
    specify 'will get callbackip with access_token' do
      server_ip_result = 'server_ip_result'
      expect(subject.client).to receive(:get).with('getcallbackip', params: { access_token: 'access_token' }).and_return(server_ip_result)
      expect(subject.callbackip).to eq server_ip_result
    end
  end

  describe '#qrcode' do
    specify 'will get showqrcode with ticket at file based api endpoint as file' do
      ticket_result = 'ticket_result'

      expect(subject.client).to receive(:get)
        .with('showqrcode', params: { ticket: 'ticket' },
                            base: Wechat::ApiBase::MP_BASE,
                            as: :file).and_return(ticket_result)
      expect(subject.qrcode('ticket')).to eq(ticket_result)
    end
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

  describe '#user_batchget' do
    specify 'will post user/info/batchget with access_token and openids' do
      user_batchget_request = { user_list: [{ openid: 'openid_subscribed', lang: 'en' }, { openid: 'openid_unsubscribe', lang: 'en' }] }
      user_batchget_result = {
        user_info_list: [{ subscribe: 1,
                           openid: 'openid_subscribed',
                           nickname: 'iWithery',
                           sex: 1,
                           language: 'zh_CN',
                           city: 'Jieyang',
                           province: 'Guangdong',
                           country: 'China',
                           headimgurl: 'http://wx.qlogo.cn/mmopen/xbIQx1GRqdvyqkMMhEaGOX802l1CyqMJNgUzKP8MeAeHFicRDSnZH7FY4XB7p8XHXIf6uJA2SCunTPicGKezDC4saKISzRj3nz/0',
                           subscribe_time: 1434093047,
                           unionid: 'oR5GjjgEhCMJFyzaVZdrxZ2zRRF4',
                           remark: '',
                           groupid: 0 },
                         { subscribe: 0,
                           openid: 'openid_unsubscribe',
                           unionid: 'oR5GjjjrbqBZbrnPwwmSxFukE41U' }] }

      expect(subject.client).to receive(:post).with('user/info/batchget', user_batchget_request.to_json, params: { access_token: 'access_token' })
        .and_return(user_batchget_result)
      expect(subject.user_batchget(%w(openid_subscribed openid_unsubscribe), 'en')).to eq(user_batchget_result)
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

  describe '#user_update_remark' do
    specify 'will post groups/getid with access_token and openid to get user groups info' do
      user_update_remark_request = { openid: 'openid', remark: 'remark' }
      user_update_remark_result = { errcode: 0, errmsg: 'ok' }
      expect(subject.client).to receive(:post)
        .with('user/info/updateremark', user_update_remark_request.to_json, params: { access_token: 'access_token' }).and_return(user_update_remark_result)
      expect(subject.user_update_remark 'openid', 'remark').to eq user_update_remark_result
    end
  end

  describe '#qrcode_create_scene' do
    qrcode_scene_result = { ticket: 'qr_code_ticket',
                            expire_seconds: 60, url: 'qr_code_ticket_pic_url' }

    specify 'will post qrcode/create with access_token, scene_id and expire_seconds' do
      scene_id = 101
      qrcode_scene_req = { expire_seconds: 60,
                           action_name: 'QR_SCENE',
                           action_info: { scene: { scene_id: scene_id } } }
      expect(subject.client).to receive(:post)
        .with('qrcode/create', qrcode_scene_req.to_json, params: { access_token: 'access_token' }).and_return(qrcode_scene_result)
      expect(subject.qrcode_create_scene(scene_id, 60)).to eq qrcode_scene_result
    end

    specify 'will post qrcode/create with access_token, scene_str and expire_seconds' do
      scene_str = 'scene_str'
      qrcode_scene_req = { expire_seconds: 60,
                           action_name: 'QR_STR_SCENE',
                           action_info: { scene: { scene_str: scene_str } } }
      expect(subject.client).to receive(:post)
        .with('qrcode/create', qrcode_scene_req.to_json, params: { access_token: 'access_token' }).and_return(qrcode_scene_result)
      expect(subject.qrcode_create_scene(scene_str, 60)).to eq qrcode_scene_result
    end
  end

  describe '#qrcode_create_limit_scene' do
    qrcode_limit_scene_result = { ticket: 'qr_code_ticket',
                                  url: 'qr_code_ticket_pic_url' }

    specify 'will post qrcode/create with access_token and scene_id' do
      scene_id = 101
      qrcode_limit_scene_req = { action_name: 'QR_LIMIT_SCENE',
                                 action_info: { scene: { scene_id: scene_id } } }
      expect(subject.client).to receive(:post)
        .with('qrcode/create', qrcode_limit_scene_req.to_json, params: { access_token: 'access_token' }).and_return(qrcode_limit_scene_result)
      expect(subject.qrcode_create_limit_scene(scene_id)).to eq qrcode_limit_scene_result
    end

    specify 'will post qrcode/create with access_token and scene_str' do
      scene_str = 'scene_str'
      qrcode_limit_str_scene_req = { action_name: 'QR_LIMIT_STR_SCENE',
                                     action_info: { scene: { scene_str: scene_str } } }
      expect(subject.client).to receive(:post)
        .with('qrcode/create', qrcode_limit_str_scene_req.to_json, params: { access_token: 'access_token' }).and_return(qrcode_limit_scene_result)
      expect(subject.qrcode_create_limit_scene(scene_str)).to eq qrcode_limit_scene_result
    end
  end

  describe '#shorturl' do
    shorturl_result = { errcode: 0, errmsg: 'ok',
                        shorturl: 'http://w.url.cn/s/AvCo6Ih' }

    specify 'will post shorturl with access_token and long_url' do
      long_url = 'http://wap.koudaitong.com/v2/showcase/goods?alias=128wi9shh&spm=h56083&redirect_count=1'
      shorturl_req = { action: 'long2short', long_url: long_url }
      expect(subject.client).to receive(:post)
        .with('shorturl', JSON.generate(shorturl_req), params: { access_token: 'access_token' }).and_return(shorturl_result)
      expect(subject.shorturl(long_url)).to eq shorturl_result
    end
  end

  describe '#message_mass_sendall' do
    specify 'will post message/mass/sendall with access_token and mpnews media_id in json' do
      ref_mpnews = { filter: { is_to_all: false, tag_id: 2 },
                     send_ignore_reprint: 0,
                     msgtype: 'mpnews',
                     mpnews: { media_id: '123dsdajkasd231jhksad' } }
      result = { errcode: 0, errmsg: 'send job submission success',
                 msg_id: 34182, msg_data_id: 206227730 }
      expect(subject.client).to receive(:post).with('message/mass/sendall', ref_mpnews.to_json, params: { access_token: 'access_token' }).and_return(result)
      expect(subject.message_mass_sendall(Wechat::Message.to_mass(tag_id: 2).ref_mpnews('123dsdajkasd231jhksad'))).to eq(result)
    end
    specify 'will post message/mass/sendall with access_token and image media_id in json' do
      ref_mpnews = { filter: { is_to_all: false, tag_id: 2 },
                     send_ignore_reprint: 0,
                     msgtype: 'image',
                     image: { media_id: '123dsdajkasd231jhksad' } }
      result = { errcode: 0, errmsg: 'send job submission success',
                 msg_id: 34182, msg_data_id: 206227730 }
      expect(subject.client).to receive(:post).with('message/mass/sendall', ref_mpnews.to_json, params: { access_token: 'access_token' }).and_return(result)
      expect(subject.message_mass_sendall(Wechat::Message.to_mass(tag_id: 2).image('123dsdajkasd231jhksad'))).to eq(result)
    end
    specify 'will post message/mass/sendall with access_token, openid and mpnews media id in json' do
      ref_mpnews_to_openid = { touser: %w(OPENID1 OPENID2),
                               send_ignore_reprint: 1,
                               msgtype: 'mpnews',
                               mpnews: { media_id: '123dsdajkasd231jhksad' } }
      result = { errcode: 0, errmsg: 'send job submission success',
                 msg_id: 34182, msg_data_id: 206227730 }
      expect(subject.client).to receive(:post).with('message/mass/sendall', ref_mpnews_to_openid.to_json, params: { access_token: 'access_token' }).and_return(result)
      expect(subject.message_mass_sendall(Wechat::Message.to(['OPENID1', 'OPENID2'], send_ignore_reprint: 1).ref_mpnews('123dsdajkasd231jhksad'))).to eq(result)
    end
  end

  describe '#message_mass_delete' do
    specify 'will post message/mass/delete with access_token and msg_id' do
      mass_delete_req = { msg_id: 30124 }
      mass_delete_result = { errcode: 0, errmsg: 'ok' }
      expect(subject.client).to receive(:post)
        .with('message/mass/delete', JSON.generate(mass_delete_req), params: { access_token: 'access_token' }).and_return(mass_delete_result)
      expect(subject.message_mass_delete(30124)).to eq mass_delete_result
    end
  end

  describe '#message_mass_preview' do
    specify 'will post message/mass/preview with access_token, openid and mpnews media id in json' do
      ref_mpnews_to_openid = { touser: 'OPENID',
                               msgtype: 'mpnews',
                               mpnews: { media_id: '123dsdajkasd231jhksad' } }
      result = { errcode: 0, errmsg: 'preview success', msg_id: 34182 }
      expect(subject.client).to receive(:post).with('message/mass/preview', ref_mpnews_to_openid.to_json, params: { access_token: 'access_token' }).and_return(result)
      expect(subject.message_mass_preview(Wechat::Message.to('OPENID').ref_mpnews('123dsdajkasd231jhksad'))).to eq(result)
    end
    specify 'will post message/mass/preview with access_token, towxname and mpnews media id in json' do
      ref_mpnews_to_openid = { towxname: '示例的微信号',
                               msgtype: 'mpnews',
                               mpnews: { media_id: '123dsdajkasd231jhksad' } }
      result = { errcode: 0, errmsg: 'preview success', msg_id: 34182 }
      expect(subject.client).to receive(:post).with('message/mass/preview', ref_mpnews_to_openid.to_json, params: { access_token: 'access_token' }).and_return(result)
      expect(subject.message_mass_preview(Wechat::Message.to(towxname: '示例的微信号').ref_mpnews('123dsdajkasd231jhksad'))).to eq(result)
    end
  end

  describe '#message_mass_get' do
    specify 'will post message/mass/get with access_token and msg_id' do
      mass_get_req = { msg_id: 201053012 }
      mass_get_result = { msg_id: 201053012, msg_status: 'SEND_SUCCESS' }
      expect(subject.client).to receive(:post)
        .with('message/mass/get', JSON.generate(mass_get_req), params: { access_token: 'access_token' }).and_return(mass_get_result)
      expect(subject.message_mass_get(201053012)).to eq mass_get_result
    end
  end

  describe '#wxa_get_wxacode' do
    wxacode_result = { errcode: 0, errmsg: 'ok',
                       url: 'wxa_code_pic_url' }

    specify 'will post wxa_get_wxacode with path, width and access_token' do
      path = 'pages/index?query=1'
      wxa_get_wxacode_req = { path: path, width: 430 }
      expect(subject.client).to receive(:post)
        .with('getwxacode', JSON.generate(wxa_get_wxacode_req),
              params: { access_token: 'access_token' }, base: Wechat::Api::WXA_BASE).and_return(wxacode_result)
      expect(subject.wxa_get_wxacode(path)).to eq wxacode_result
    end
  end

  describe '#wxa_get_wxacode_unlimit' do
    wxacode_result = { errcode: 0, errmsg: 'ok',
                       url: 'wxa_code_pic_url' }

    specify 'will post wxa_get_wxacode_unlimit with scene, page, width and access_token' do
      scene = 'query=1'
      page = 'pages/index'
      wxa_get_wxacode_unlimit_req = { scene: scene, page: page, width: 430 }
      expect(subject.client).to receive(:post)
        .with('getwxacodeunlimit', JSON.generate(wxa_get_wxacode_unlimit_req),
              params: { access_token: 'access_token' }, base: Wechat::Api::WXA_BASE).and_return(wxacode_result)
      expect(subject.wxa_get_wxacode_unlimit(scene, page)).to eq wxacode_result
    end
  end

  describe '#wxa_create_qrcode' do
    qrcode_result = { errcode: 0, errmsg: 'ok',
                      url: 'qr_code_pic_url' }

    specify 'will post wxa_create_qrcode with path, width and access_token' do
      path = 'pages/index?query=1'
      wxa_create_qrcode_req = { path: path, width: 430 }
      expect(subject.client).to receive(:post)
        .with('wxaapp/createwxaqrcode', JSON.generate(wxa_create_qrcode_req), params: { access_token: 'access_token' }).and_return(qrcode_result)
      expect(subject.wxa_create_qrcode(path)).to eq qrcode_result
    end
  end

  describe '#wxa_msg_sec_check' do
    msg_sec_check_result = { errcode: 87014, errmsg: 'risky content' }

    specify 'will post wxa_msg_sec_check with risky content' do
      risky_content = '特3456书yuuo莞6543李zxcz蒜7782法fgnv级'
      expect(subject.client).to receive(:post)
        .with('msg_sec_check', JSON.generate(content: risky_content),
              params: { access_token: 'access_token' }, base: Wechat::Api::WXA_BASE).and_return(msg_sec_check_result)
      expect(subject.wxa_msg_sec_check(risky_content)).to eq msg_sec_check_result
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

  describe '#menu_addconditional' do
    specify 'will post menu/addconditional with access_token and json_data' do
      conditional_menu = { button: [{ type: 'view', name: 'Testing', url: 'http://xxx.proxy.qqbrowser.cc' }],
                           matchrule: { client_platform_type: 1 } }
      expect(subject.client).to receive(:post).with('menu/addconditional', conditional_menu.to_json, params: { access_token: 'access_token' }).and_return(true)
      expect(subject.menu_addconditional(conditional_menu)).to be true
    end
  end

  describe '#menu_trymatch' do
    specify 'will post menu/trymatch with access_token and user_id in json' do
      user_menu = { user_id: 'weixin' }
      menu_result = 'menu_result'
      expect(subject.client).to receive(:post).with('menu/trymatch', user_menu.to_json, params: { access_token: 'access_token' }).and_return(menu_result)
      expect(subject.menu_trymatch('weixin')).to eq(menu_result)
    end
  end

  describe '#menu_delconditional' do
    specify 'will post menu/delconditional with access_token and user_id in json' do
      menuid = { menuid: 'menuid' }
      delconditional_result = { errcode: 0, errmsg: 'ok' }
      expect(subject.client).to receive(:post).with('menu/delconditional', menuid.to_json, params: { access_token: 'access_token' }).and_return(delconditional_result)
      expect(subject.menu_delconditional('menuid')).to eq(delconditional_result)
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

  describe '#media_hq' do
    specify 'will get media/get/jssdk with access_token and media_id at file based api endpoint as file' do
      media_hq_result = 'raw speex file format' # http://speex.org/

      expect(subject.client).to receive(:get)
        .with('media/get/jssdk', params: { access_token: 'access_token', media_id: 'media_id' },
                                 as: :file).and_return(media_hq_result)
      expect(subject.media_hq('media_id')).to eq(media_hq_result)
    end
  end

  describe '#media_create' do
    specify 'will post media/upload with access_token, type and media payload at file based api endpoint' do
      file = 'README.md'
      expect(subject.client).to receive(:post_file)
        .with('media/upload', file,
              params: { type: 'image', access_token: 'access_token' }).and_return(true)
      expect(subject.media_create('image', file)).to be true
    end
  end

  describe '#media_uploadnews' do
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
    specify 'will post media/media_uploadnews with access_token and mpnews in json' do
      mpnews = {
        articles: [
          {
            thumb_media_id: 'qI6_Ze_6PtV7svjolgs-rN6stStuHIjs9_DidOHaj0Q-mwvBelOXCFZiq2OsIU-p',
            title: 'Happy Day',
            content: 'content',
            author: 'xxx',
            content_source_url: 'www.qq.com',
            digest: 'digest',
            show_cover_pic: 1
          },
          {
            thumb_media_id: 'qI6_Ze_6PtV7svjolgs-rN6stStuHIjs9_DidOHaj0Q-mwvBelOXCFZiq2OsIU-p',
            title: 'Happy Day',
            content: 'content',
            author: 'xxx',
            content_source_url: 'www.qq.com',
            digest: 'digest',
            show_cover_pic: 0
          }
        ]
      }
      result = { type: 'news', media_id: 'CsEf3ldqkAYJAU6EJeIkStVDSvffUJ54vqbThMgplD-VJXXof6ctX5fI6-aYyUiQ', created_at: 1391857799 }
      expect(subject.client).to receive(:post).with('media/uploadnews', mpnews.to_json, params: { access_token: 'access_token' }).and_return(result)
      expect(subject.media_uploadnews(Wechat::Message.new(MsgType: 'mpnews').mpnews(items))).to eq(result)
    end
  end

  describe '#material' do
    specify 'will post material/get_material with access_token and media_id as payload at file based api endpoint as file' do
      material_result = 'material_tmp_file'

      allow(ActiveSupport::Deprecation).to receive(:warn)

      expect(subject.client).to receive(:post)
        .with('material/get_material', { media_id: 'media_id' }.to_json, params: { access_token: 'access_token' },
                              as: :file).and_return(material_result)
      expect(subject.material('media_id')).to eq(material_result)

      expect(ActiveSupport::Deprecation).to have_received(:warn)
        .with('material is deprecated. use get_material instead.')
    end
  end

  describe '#get_material' do
    specify 'will post material/get_material with access_token and media_id as payload at file based api endpoint as file' do
      material_result = 'material_tmp_file'

      expect(subject.client).to receive(:post)
        .with('material/get_material', { media_id: 'media_id' }.to_json, params: { access_token: 'access_token' },
                              as: :file).and_return(material_result)
      expect(subject.get_material('media_id')).to eq(material_result)
    end
  end

  describe '#material_count' do
    specify 'will get material_count with access_token' do
      material_count_result = { voice_count: 1,
                                video_count: 2,
                                image_count: 3,
                                news_count: 4 }
      expect(subject.client).to receive(:get)
        .with('material/get_materialcount', params: { access_token: 'access_token' }).and_return(material_count_result)
      expect(subject.material_count).to eq material_count_result
    end
  end

  describe '#material_list' do
    specify 'will get material list with access_token' do
      material_list_request = { type: 'image', offset: 0, count: 20 }
      material_list_result = { total_count: 1, item_count: 1,
                               item: [{ media_id: 'media_id', name: 'name', update_time: 12345, url: 'url' }] }
      expect(subject.client).to receive(:post)
        .with('material/batchget_material', material_list_request.to_json, params: { access_token: 'access_token' }).and_return(material_list_result)
      expect(subject.material_list('image', 0, 20)).to eq material_list_result
    end
  end

  describe '#material_add' do
    specify 'will post material/add_material with access_token, type and media payload at file based api endpoint' do
      file = 'README.md'
      expect(subject.client).to receive(:post_file)
        .with('material/add_material', file,
              params: { type: 'image', access_token: 'access_token' }).and_return(true)
      expect(subject.material_add('image', file)).to be true
    end
  end

  describe '#material_delete' do
    specify 'will post material/del_material with access_token and media_id in payload' do
      media_id = 'media_id'
      material_delete_result = { errcode: 0, errmsg: 'deleted' }
      payload = { media_id: media_id }
      expect(subject.client).to receive(:post)
        .with('material/del_material', payload.to_json,
              params: { access_token: 'access_token' }).and_return(material_delete_result)
      expect(subject.material_delete(media_id)).to eq material_delete_result
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
        .with('message/custom/send', JSON.generate(payload),
              params: { access_token: 'access_token' }, content_type: :json).and_return(true)

      expect(subject.custom_message_send Wechat::Message.to('openid').text('message content')).to be true
    end
  end

  describe '#template_message_send' do
    specify 'will post message/custom/send with access_token, and json payload' do
      payload = { touser: 'OPENID',
                  template_id: 'ngqIpbwh8bUfcSsECmogfXcV14J0tQlEpBO27izEYtY',
                  url: 'http://weixin.qq.com/download',
                  topcolor: '#FF0000',
                  data: { first: { value: '恭喜你购买成功！', color: '#173177' },
                          keynote1: { value: '巧克力', color: '#173177' },
                          keynote2: { value: '39.8元', color: '#173177' },
                          keynote3: { value: '2014年9月16日', color: '#173177' },
                          remark: { value: '欢迎再次购买！', color: '#173177' } } }
      response_result = { errcode: 0, errmsg: 'ok', msgid: 332 }

      expect(subject.client).to receive(:post)
        .with('message/template/send', payload.to_json,
              params: { access_token: 'access_token' }, content_type: :json).and_return(response_result)

      expect(subject.template_message_send(payload)).to eq response_result
    end
  end

  describe '#customservice_getonlinekflist' do
    specify 'will get customservice/getonlinekflist with access_token' do
      kf_list = { kf_online_list: [{ kf_account: 'test1@test',
                                     status: 1,
                                     kf_id: '1001',
                                     auto_accept: 0,
                                     accepted_case: 1 },
                                   { kf_account: 'test2@test',
                                     status: 1,
                                     kf_id: '1002',
                                     auto_accept: 0,
                                     accepted_case: 2 }] }
      expect(subject.client).to receive(:get).with('customservice/getonlinekflist', params: { access_token: 'access_token' }).and_return(kf_list)
      expect(subject.customservice_getonlinekflist).to eq(kf_list)
    end
  end

  describe '#tags' do
    specify 'will get tags/get with access_token' do
      tags_result = { tags: [{ id: 1,
                               name: '每天一罐可乐星人',
                               count: 0 # fans count under this tag
                             },
                             { id: 2, name: '星标组', count: 0 },
                             { id: 127, name: '广东', count: 5 }] }
      expect(subject.client).to receive(:get)
        .with('tags/get', params: { access_token: 'access_token' }).and_return(tags_result)
      expect(subject.tags).to eq tags_result
    end
  end

  describe '#tag_create' do
    specify 'will post tags/create with access_token and tag_name' do
      payload = { tag: { name: '广东' } }
      tag_result = { tag: { id: 134, # tag id
                            name: '广东' } }
      expect(subject.client).to receive(:post)
        .with('tags/create', payload.to_json, params: { access_token: 'access_token' }).and_return(tag_result)
      expect(subject.tag_create('广东')).to eq tag_result
    end
  end

  describe '#tag_update' do
    specify 'will post tags/update with access_token, id and new_tag_name' do
      payload = { tag: { id: 134, name: '广东人' } }
      result = { errcode: 0, errmsg: 'ok' }
      expect(subject.client).to receive(:post)
        .with('tags/update', payload.to_json, params: { access_token: 'access_token' }).and_return(result)
      expect(subject.tag_update(134, '广东人')).to eq result
    end
  end

  describe '#tag_delete' do
    specify 'will post tags/delete with access_token and tagid' do
      payload = { tag: { id: 134 } }
      tag_delete_result = { errcode: 0, errmsg: 'ok' }
      expect(subject.client).to receive(:post)
        .with('tags/delete', payload.to_json, params: { access_token: 'access_token' }).and_return(tag_delete_result)
      expect(subject.tag_delete(134)).to eq tag_delete_result
    end
  end

  describe '#tag_add_user' do
    specify 'will post tags/members/batchtagging with access_token, openids and tagid' do
      payload = { openid_list: ['ocYxcuAEy30bX0NXmGn4ypqx3tI0', # fans openid list
                                'ocYxcuBt0mRugKZ7tGAHPnUaOW7Y'], tagid: 134 }
      tag_add_user_result = { errcode: 0, errmsg: 'ok' }
      expect(subject.client).to receive(:post)
        .with('tags/members/batchtagging', payload.to_json, params: { access_token: 'access_token' }).and_return(tag_add_user_result)
      expect(subject.tag_add_user(134, %w(ocYxcuAEy30bX0NXmGn4ypqx3tI0 ocYxcuBt0mRugKZ7tGAHPnUaOW7Y))).to eq tag_add_user_result
    end
  end

  describe '#tag_del_user' do
    specify 'will post tags/members/batchuntagging with access_token, openids and tagid' do
      payload = { openid_list: ['ocYxcuAEy30bX0NXmGn4ypqx3tI0', # fans openid list
                                'ocYxcuBt0mRugKZ7tGAHPnUaOW7Y'], tagid: 134 }
      tag_add_user_result = { errcode: 0, errmsg: 'ok' }
      expect(subject.client).to receive(:post)
        .with('tags/members/batchuntagging', payload.to_json, params: { access_token: 'access_token' }).and_return(tag_add_user_result)
      expect(subject.tag_del_user(134, %w(ocYxcuAEy30bX0NXmGn4ypqx3tI0 ocYxcuBt0mRugKZ7tGAHPnUaOW7Y))).to eq tag_add_user_result
    end
  end

  describe '#tag' do
    specify 'will post user/tag/get with access_token and tagid' do
      payload = { tagid: 134, next_openid: '' } # next_openid empty will get from begin
      tag_result = { count: 2, # total tag fans number
                     data: { openid: ['ocYxcuAEy30bX0NXmGn4ypqx3tI0', # fans list
                                      'ocYxcuBt0mRugKZ7tGAHPnUaOW7Y'] },
                     next_openid: 'ocYxcuBt0mRugKZ7tGAHPnUaOW7Y' } # last openid of this fetch fans list
      expect(subject.client).to receive(:post)
        .with('user/tag/get', payload.to_json, params: { access_token: 'access_token' }).and_return(tag_result)
      expect(subject.tag(134)).to eq tag_result
    end
  end

  describe '#getusersummary' do
    usersummary_result = { list: [
      { ref_date: '2014-12-07',
        user_source: 0,
        new_user: 0,
        cancel_user: 0 }
    ] }

    specify 'will post getusersummary with begin_date, end_date and access_token' do
      getusersummary_req = { begin_date: '2014-12-07', end_date: '2014-12-08' }
      expect(subject.client).to receive(:post)
        .with('getusersummary', JSON.generate(getusersummary_req),
              params: { access_token: 'access_token' }, base: Wechat::Api::DATACUBE_BASE).and_return(usersummary_result)
      expect(subject.getusersummary('2014-12-07', '2014-12-08')).to eq usersummary_result
    end
  end

  describe '#getusercumulate' do
    usercumulate_result = { list: [
      { ref_date: '2014-12-07',
        cumulate_user: 1217056 }
    ] }

    specify 'will post getusercumulate with begin_date, end_date and access_token' do
      getusercumulate_req = { begin_date: '2014-12-07', end_date: '2014-12-08' }
      expect(subject.client).to receive(:post)
        .with('getusercumulate', JSON.generate(getusercumulate_req),
              params: { access_token: 'access_token' }, base: Wechat::Api::DATACUBE_BASE).and_return(usercumulate_result)
      expect(subject.getusercumulate('2014-12-07', '2014-12-08')).to eq usercumulate_result
    end
  end

  describe '#web_access_token' do
    specify 'will get access_token, refresh_token and openid with authorization_code' do
      oauth_result = { access_token: 'ACCESS_TOKEN',
                       expires_in: 7200,
                       refresh_token: 'REFRESH_TOKEN',
                       openid: 'OPENID',
                       scope: 'snsapi_userinfo' }
      expect(subject.client).to receive(:get)
        .with('oauth2/access_token', params: { appid: 'appid',
                                               secret: 'secret',
                                               code: 'code',
                                               grant_type: 'authorization_code' }, base: Wechat::Api::OAUTH2_BASE).and_return(oauth_result)
      expect(subject.web_access_token('code')).to eq(oauth_result)
    end
  end

  describe '#web_auth_access_token' do
    specify 'will validate web access token with web_access_token and openid' do
      oauth_result = { errcode: 0, errmsg: 'ok' }
      expect(subject.client).to receive(:get)
        .with('auth', params: { access_token: 'web_access_token',
                                        openid: 'openid' }, base: Wechat::Api::OAUTH2_BASE).and_return(oauth_result)
      expect(subject.web_auth_access_token('web_access_token', 'openid')).to eq(oauth_result)
    end
  end

  describe '#web_refresh_access_token' do
    specify 'will get access_token, refresh_token and openid with user_refresh_token' do
      oauth_result = { access_token: 'ACCESS_TOKEN',
                       expires_in: 7200,
                       refresh_token: 'REFRESH_TOKEN',
                       openid: 'OPENID',
                       scope: 'snsapi_userinfo' }
      expect(subject.client).to receive(:get)
        .with('oauth2/refresh_token', params: { appid: 'appid',
                                                grant_type: 'refresh_token',
                                                refresh_token: 'user_refresh_token' }, base: Wechat::Api::OAUTH2_BASE).and_return(oauth_result)
      expect(subject.web_refresh_access_token('user_refresh_token')).to eq(oauth_result)
    end
  end

  describe '#web_userinfo' do
    specify 'will get user_info with web_access_token and openid' do
      user_info = { openid: 'OPENID',
                    nickname: 'NICKNAME',
                    sex: '1',
                    province: 'PROVINCE',
                    city: 'CITY',
                    country: 'COUNTRY',
                    headimgurl: 'http://wx.qlogo.cn/mmopen/g3MonUZtNHkdmzicIlibx6iaFqAc56vxLSUfpb6n5WKSYVY0ChQKkiaJSgQ1dZuTOgvLLrhJbERQQ4eMsv84eavHiaiceqxibJxCfHe/46',
                    privilege: %w(PRIVILEGE1 PRIVILEGE2),
                    unionid: 'o6_bmasdasdsad6_2sgVt7hMZOPfL' }
      expect(subject.client).to receive(:get)
        .with('userinfo', params: { access_token: 'web_access_token',
                                    openid: 'openid',
                                    lang: 'zh_CN' }, base: Wechat::Api::OAUTH2_BASE).and_return(user_info)
      expect(subject.web_userinfo('web_access_token', 'openid')).to eq(user_info)
    end
  end

  describe '#list_message_template' do
    specify 'will post template/get_all_private_template with access_token as params' do
      response_result = {
        template_list: [{
          template_id: 'iPk5sOIt5X_flOVKn5GrTFpncEYTojx6ddbt8WYoV5s',
          title: '领取奖金提醒',
          primary_industry: 'IT科技',
          deputy_industry: '互联网|电子商务',
          content: "{ {result.DATA} }\n\n领奖金额:{ {withdrawMoney.DATA} }\n领奖  时间:{ {withdrawTime.DATA} }\n银行信息:{ {cardInfo.DATA} }\n到账时间:  { {arrivedTime.DATA} }\n{ {remark.DATA} }",
          example: "您已提交领奖申请\n\n领奖金额：xxxx元\n领奖时间：2013-10-10 12:22:22\n银行信息：xx银行(尾号xxxx)\n到账时间：预计xxxxxxx\n\n预计将于xxxx到达您的银行卡"
        }]
      }

      expect(subject.client).to receive(:get)
        .with('template/get_all_private_template',
              params: { access_token: 'access_token' }).and_return(response_result)

      expect(subject.list_message_template).to eq response_result
    end
  end

  describe '#add_message_template' do
    specify 'will post template/api_add_template with access_token, and template_id_short in body' do
      response_result = {
        errcode: 0,
        errmsg: 'ok',
        template_id: 'Doclyl5uP7Aciu-qZ7mJNPtWkbkYnWBWVja26EGbNyk'
      }

      expect(subject.client).to receive(:post)
        .with('template/api_add_template', { template_id_short: 'TM00015' }.to_json,
              params: { access_token: 'access_token' }).and_return(response_result)

      expect(subject.add_message_template('TM00015')).to eq response_result
    end
  end

  describe '#del_message_template' do
    specify 'will post template/del_private_template with access_token, and template_id as params' do
      response_result = {
        errcode: 0,
        errmsg: 'ok'
      }

      expect(subject.client).to receive(:post)
        .with('template/del_private_template', { template_id: 'Dyvp3-Ff0cnail_CDSzk1fIc6-9lOkxsQE7exTJbwUE' }.to_json,
              params: { access_token: 'access_token' }).and_return(response_result)

      expect(subject.del_message_template('Dyvp3-Ff0cnail_CDSzk1fIc6-9lOkxsQE7exTJbwUE')).to eq response_result
    end
  end

  describe '#clear_quota' do
    specify 'will post clear_quota with access_token, and appid as params' do
      response_result = {
        errcode: 0,
        errmsg: 'ok'
      }

      expect(subject.client).to receive(:post)
        .with('clear_quota', { appid: Wechat.config[:appid] }.to_json,
              params: { access_token: 'access_token' }).and_return(response_result)

      expect(subject.clear_quota).to eq response_result
    end
  end

  describe '#addvoicetorecofortext' do
    specify 'will post media/voice/addvoicetorecofortext, file in body with access_token, format, voice_id and lang as params.' do
      file = File.open('README.md')
      response_result = {
        errcode: 0,
        errmsg: 'ok'
      }

      expect(subject.client).to receive(:post_file)
        .with('media/voice/addvoicetorecofortext', file,
          params: { access_token: 'access_token', format: 'mp3', voice_id: 'xxxxxx', lang: 'zh_CN' })
        .and_return(response_result)
      expect(subject.addvoicetorecofortext('xxxxxx', file)).to eq response_result
    end
  end

  describe '#queryrecoresultfortext' do
    specify 'will post media/voice/queryrecoresultfortext with access_token, voice_id and lang as params.' do
      response_result = { result: "xxxxxxxxxxxxxxxxxx" }

      expect(subject.client).to receive(:post)
        .with('media/voice/queryrecoresultfortext', nil,
          params: { access_token: 'access_token', voice_id: 'xxxxxx', lang: 'zh_CN' })
        .and_return(response_result)
      expect(subject.queryrecoresultfortext('xxxxxx')).to eq response_result
    end
  end

  describe '#translatecontent' do
    specify 'will post media/voice/translatecontent with access_token, lfrom and lto as params and content in body' do
      response_result = { from_content: "xxxxxxxx", to_content: "xxxxxxxx" }

      expect(subject.client).to receive(:post)
        .with('media/voice/translatecontent', 'xxxxxxxx',
          params: { access_token: 'access_token', lfrom: 'zh_CN', lto: 'en_US' })
        .and_return(response_result)
      expect(subject.translatecontent('xxxxxxxx')).to eq response_result
    end
  end
end
