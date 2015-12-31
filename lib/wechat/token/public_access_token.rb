require 'wechat/token/access_token_base'

module Wechat
  module Token
    class PublicAccessToken < AccessTokenBase
      def refresh
        data = client.get('token', params: { grant_type: 'client_credential', appid: appid, secret: secret })
        write_token_to_file(data)
      end
    end
  end
end
