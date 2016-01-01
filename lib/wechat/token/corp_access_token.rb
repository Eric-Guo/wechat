require 'wechat/token/access_token_base'

module Wechat
  module Token
    class CorpAccessToken < AccessTokenBase
      def refresh
        data = client.get('gettoken', params: { corpid: appid, corpsecret: secret })
        write_token_to_file(data)
        read_token_from_file
      end
    end
  end
end
