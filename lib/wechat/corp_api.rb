# frozen_string_literal: true

require_relative 'corp_api/user'
require_relative 'corp_api/department'
require_relative 'corp_api/tag'
require_relative 'corp_api/agent'
require_relative 'corp_api/batch'
require_relative 'corp_api/material'
require_relative 'corp_api/message'
require_relative 'corp_api/menu'

module Wechat
  class CorpApi < ApiBase
    include Wechat::CorpApi::User
    include Wechat::CorpApi::Department
    include Wechat::CorpApi::Tag
    include Wechat::CorpApi::Agent
    include Wechat::CorpApi::Batch
    include Wechat::CorpApi::Material
    include Wechat::CorpApi::Message
    include Wechat::CorpApi::Menu
    attr_reader :agentid

    def initialize(api_config, agentid)
      super()
      @client = HttpClient.new(QYAPI_BASE, api_config.network_setting)
      @access_token = Token::CorpAccessToken.new(@client, api_config.appid, api_config.secret, api_config.token_file)
      @agentid = agentid
      @jsapi_ticket = Ticket::CorpJsapiTicket.new(@client, @access_token, api_config.jsapi_ticket_file)
      @qcloud = nil
    end

    def get_externalcontact(external_userid, cursor = nil)
      # https://developer.work.weixin.qq.com/document/path/92114
      get 'externalcontact/get', params: { external_userid: external_userid, cursor: cursor }
    end

    def follow_user_list
      # https://developer.work.weixin.qq.com/document/path/92576
      get 'externalcontact/get_follow_user_list'
    end

    def batch_get_by_user(userid_list, cursor: nil, limit: nil)
      # https://developer.work.weixin.qq.com/document/path/93010
      post 'externalcontact/batch/get_by_user', JSON.generate(userid_list: userid_list, cursor: cursor, limit: limit)
    end

    def checkin(useridlist, starttime = Time.now.beginning_of_day, endtime = Time.now.end_of_day, opencheckindatatype = 3)
      post 'checkin/getcheckindata', JSON.generate(
        opencheckindatatype: opencheckindatatype,
        starttime: starttime.to_i,
        endtime: endtime.to_i,
        useridlist: useridlist
      )
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
