# frozen_string_literal: true

module Wechat
  class CorpApi < ApiBase
    attr_reader :agentid

    def initialize(appid, secret, token_file, agentid, network_setting, jsapi_ticket_file)
      super()
      @client = HttpClient.new(QYAPI_BASE, network_setting)
      @access_token = Token::CorpAccessToken.new(@client, appid, secret, token_file)
      @agentid = agentid
      @jsapi_ticket = Ticket::CorpJsapiTicket.new(@client, @access_token, jsapi_ticket_file)
      @qcloud = nil
    end

    def agent_list
      get 'agent/list'
    end

    def agent(agentid)
      get 'agent/get', params: { agentid: agentid }
    end

    def checkin(useridlist, starttime = Time.now.beginning_of_day, endtime = Time.now.end_of_day, opencheckindatatype = 3)
      post 'checkin/getcheckindata', JSON.generate(
        opencheckindatatype: opencheckindatatype,
        starttime: starttime.to_i,
        endtime: endtime.to_i,
        useridlist: useridlist
      )
    end

    def user(userid)
      get 'user/get', params: { userid: userid }
    end

    def getuserinfo(code)
      get 'user/getuserinfo', params: { code: code }
    end

    def convert_to_openid(userid)
      post 'user/convert_to_openid', JSON.generate(userid: userid, agentid: agentid)
    end

    def convert_to_userid(openid)
      post 'user/convert_to_userid', JSON.generate(openid: openid)
    end

    def invite_user(userid)
      post 'invite/send', JSON.generate(userid: userid)
    end

    def user_auth_success(userid)
      get 'user/authsucc', params: { userid: userid }
    end

    def user_create(user)
      post 'user/create', JSON.generate(user)
    end

    def user_delete(userid)
      get 'user/delete', params: { userid: userid }
    end

    def user_batchdelete(useridlist)
      post 'user/batchdelete', JSON.generate(useridlist: useridlist)
    end

    def batch_job_result(jobid)
      get 'batch/getresult', params: { jobid: jobid }
    end

    def batch_replaceparty(media_id)
      post 'batch/replaceparty', JSON.generate(media_id: media_id)
    end

    def batch_syncuser(media_id)
      post 'batch/syncuser', JSON.generate(media_id: media_id)
    end

    def batch_replaceuser(media_id)
      post 'batch/replaceuser', JSON.generate(media_id: media_id)
    end

    def department_create(name, parentid)
      post 'department/create', JSON.generate(name: name, parentid: parentid)
    end

    def department_delete(departmentid)
      get 'department/delete', params: { id: departmentid }
    end

    def department_update(departmentid, name = nil, parentid = nil, order = nil)
      post 'department/update', JSON.generate({ id: departmentid, name: name, parentid: parentid, order: order }.compact)
    end

    def department(departmentid = 1)
      get 'department/list', params: { id: departmentid }
    end

    def user_simplelist(department_id, fetch_child = 0, status = 0)
      get 'user/simplelist', params: { department_id: department_id, fetch_child: fetch_child, status: status }
    end

    def user_list(department_id, fetch_child = 0, status = 0)
      get 'user/list', params: { department_id: department_id, fetch_child: fetch_child, status: status }
    end

    def tag_create(tagname, tagid = nil)
      post 'tag/create', JSON.generate(tagname: tagname, tagid: tagid)
    end

    def tag_update(tagid, tagname)
      post 'tag/update', JSON.generate(tagid: tagid, tagname: tagname)
    end

    def tag_delete(tagid)
      get 'tag/delete', params: { tagid: tagid }
    end

    def tags
      get 'tag/list'
    end

    def tag(tagid)
      get 'tag/get', params: { tagid: tagid }
    end

    def tag_add_user(tagid, userids = nil, departmentids = nil)
      post 'tag/addtagusers', JSON.generate(tagid: tagid, userlist: userids, partylist: departmentids)
    end

    def tag_del_user(tagid, userids = nil, departmentids = nil)
      post 'tag/deltagusers', JSON.generate(tagid: tagid, userlist: userids, partylist: departmentids)
    end

    def menu
      get 'menu/get', params: { agentid: agentid }
    end

    def menu_delete
      get 'menu/delete', params: { agentid: agentid }
    end

    def menu_create(menu)
      # 微信不接受 7bit escaped json(eg \uxxxx)，中文必须 UTF-8 编码，这可能是个安全漏洞
      post 'menu/create', JSON.generate(menu), params: { agentid: agentid }
    end

    def material_count
      get 'material/get_count', params: { agentid: agentid }
    end

    def material_list(type, offset, count)
      post 'material/batchget', JSON.generate(type: type, agentid: agentid, offset: offset, count: count)
    end

    def material(media_id)
      ActiveSupport::Deprecation.warn('material is deprecated. use get_material instead.')

      post 'material/get_material', JSON.generate(media_id: media_id), params: { agentid: agentid }, as: :file
    end

    def get_material(media_id)
      post 'material/get_material', JSON.generate(media_id: media_id), params: { agentid: agentid }, as: :file
    end

    def material_add(type, file)
      post_file 'material/add_material', file, params: { type: type, agentid: agentid }
    end

    def material_delete(media_id)
      get 'material/del', params: { media_id: media_id, agentid: agentid }
    end

    def message_send(userid, message)
      post 'message/send', Message.to(userid).text(message).agent_id(agentid).to_json, content_type: :json
    end

    def news_message_send(userid, title, description, link_url, pic_url)
      post 'message/send', Message.to(userid).news([{ title: title,
                                                      description: description,
                                                      url: link_url,
                                                      pic_url: pic_url }])
                                  .agent_id(agentid).to_json, content_type: :json
    end

    def custom_message_send(message)
      post 'message/send', message.is_a?(Wechat::Message) ? message.agent_id(agentid).to_json : JSON.generate(message.merge(agent_id: agentid)), content_type: :json
    end

    def msgaudit_get_permit_user_list(type = nil)
      post 'msgaudit/get_permit_user_list', JSON.generate(type: type)
    end

    def msgaudit_check_single_agree(info)
      post 'msgaudit/get_permit_user_list', JSON.generate(info: info)
    end

    def msgaudit_check_room_agree(roomid)
      post 'msgaudit/check_room_agree', JSON.generate(roomid: roomid)
    end

    def msgaudit_groupchat(roomid)
      post 'msgaudit/groupchat/get', JSON.generate(roomid: roomid)
    end
  end
end
