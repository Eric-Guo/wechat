module Wechat
  module CorpApi
    module User
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

      def user_simplelist(department_id, fetch_child = 0, status = 0)
        get 'user/simplelist', params: { department_id: department_id, fetch_child: fetch_child, status: status }
      end

      def user_list(department_id, fetch_child = 0, status = 0)
        get 'user/list', params: { department_id: department_id, fetch_child: fetch_child, status: status }
      end
    end
  end
end
