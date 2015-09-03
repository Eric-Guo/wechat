require 'wechat/api_base'
require 'wechat/client'
require 'wechat/access_token'

module Wechat
  class CorpAccessToken < AccessToken
    def refresh
      data = client.get('gettoken', params: { corpid: appid, corpsecret: secret })
      data.merge!(created_at: Time.now.to_i)
      File.write(token_file, data.to_json) if valid_token(data)
      @token_data = data
    end
  end

  class CorpApi < ApiBase
    attr_reader :agentid

    API_BASE = 'https://qyapi.weixin.qq.com/cgi-bin/'

    def initialize(appid, secret, token_file, agentid, skip_verify_ssl)
      @client = Client.new(API_BASE, skip_verify_ssl)
      @access_token = CorpAccessToken.new(@client, appid, secret, token_file)
      @agentid = agentid
    end

    def user(userid)
      get('user/get', params: { userid: userid })
    end

    def invite_user(userid)
      post 'invite/send', JSON.generate(userid: userid)
    end

    def user_auth_success(userid)
      get('user/authsucc', params: { userid: userid })
    end

    def department(departmentid = 1)
      get('department/list', params: { id: departmentid })
    end

    def menu
      get('menu/get', params: { agentid: agentid })
    end

    def menu_delete
      get('menu/delete', params: { agentid: agentid })
    end

    def menu_create(menu)
      # 微信不接受7bit escaped json(eg \uxxxx), 中文必须UTF-8编码, 这可能是个安全漏洞
      post 'menu/create', JSON.generate(menu), params: { agentid: agentid }
    end

    def message_send(openid, message)
      post 'message/send', Message.to(openid).text(message).agent_id(agentid).to_json, content_type: :json
    end
  end
end
