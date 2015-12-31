require 'wechat/token/access_token'

module Wechat
  module Token
    class CorpAccessToken < AccessToken
      def refresh
        data = client.get('gettoken', params: { corpid: appid, corpsecret: secret })
        write_token_to_file(data)
      end
    end
  end
end
