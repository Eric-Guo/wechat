module Wechat
  module Token
    class AccessTokenBase
      attr_reader :client, :appid, :secret, :token_file, :access_token, :token_life_in_seconds, :got_token_at

      def initialize(client, appid, secret, token_file)
        @appid = appid
        @secret = secret
        @client = client
        @token_file = token_file
        @random_generator = Random.new
      end

      def token
        # Possible two worker running, one worker refresh token, other unaware, so must read every time
        read_token_from_file
        refresh if remain_life_seconds < @random_generator.rand(30..3 * 60)
        access_token
      end

      protected

      def read_token_from_file
        td = JSON.parse(File.read(token_file))
        @got_token_at = td['got_token_at'].to_i
        @token_life_in_seconds = td['expires_in'].to_i
        @access_token = td['access_token']
      rescue JSON::ParserError, Errno::ENOENT
        refresh
      end

      def write_token_to_file(token_hash)
        token_hash.merge!('got_token_at'.freeze => Time.now.to_i)
        File.write(token_file, token_hash.to_json)
        @got_token_at = token_hash['got_token_at'].to_i
        @token_life_in_seconds = token_hash['expires_in'].to_i
        @access_token = token_hash['access_token']
      end

      def remain_life_seconds
        token_life_in_seconds - (Time.now.to_i - got_token_at)
      end
    end
  end
end
