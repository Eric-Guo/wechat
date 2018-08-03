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
        read_token_from_store
        refresh if remain_life_seconds < @random_generator.rand(30..3 * 60)
        access_token
      end

      protected

      def read_token_from_store
        td = read_token
        @token_life_in_seconds = td.fetch('token_expires_in').to_i
        @got_token_at = td.fetch('got_token_at').to_i
        @access_token = td.fetch('access_token') # return access_token same time
      rescue JSON::ParserError, Errno::ENOENT, KeyError, TypeError
        refresh
      end

      def write_token_to_store(token_hash)
        raise InvalidCredentialError unless token_hash.is_a?(Hash) && token_hash['access_token']

        token_hash['got_token_at'.freeze] = Time.now.to_i
        token_hash['token_expires_in'.freeze] = token_hash.delete('expires_in')
        write_token(token_hash)
      end

      def read_token
        JSON.parse(File.read(token_file))
      end

      def write_token(token_hash)
        File.write(token_file, token_hash.to_json)
      end

      def remain_life_seconds
        token_life_in_seconds - (Time.now.to_i - got_token_at)
      end
    end
  end
end
