module Wechat
  class AccessToken
    attr_reader :client, :appid, :secret, :token_file, :token_data, :access_token, :token_life_in_seconds, :got_token_at

    def initialize(client, appid, secret, token_file)
      @appid = appid
      @secret = secret
      @client = client
      @token_file = token_file
      @random_generator = Random.new
    end

    def token
      begin
        @token_data ||= JSON.parse(File.read(token_file))
        created_at = token_data['created_at'].to_i
        expires_in = token_data['expires_in'].to_i
        fail 'token_data may be expired' if Time.now.to_i - created_at >= expires_in - @random_generator.rand(30..3 * 60)
      rescue
        refresh
      end
      valid_token(@token_data)
    end

    def refresh
      data = client.get('token', params: { grant_type: 'client_credential', appid: appid, secret: secret })
      data.merge!('created_at'.freeze => Time.now.to_i)
      File.write(token_file, data.to_json) if valid_token(data)
      @token_data = data
    end

    private

    def read_token_from_file
      td = JSON.parse(File.read(token_file))
      @got_token_at = td['got_token_at'].to_i
      @token_life_in_seconds = td['expires_in'].to_i
      @access_token = td['access_token']
    end

    def write_token_to_file(token_hash)
      token_hash.merge!('got_token_at'.freeze => Time.now.to_i)
      File.write(token_file, token_hash.to_json) if valid_token(token_hash)
    end

    def remain_life_seconds
      @token_life_in_seconds - (Time.now.to_i - @got_token_at)
    end

    def valid_token(token_data)
      access_token = token_data['access_token']
      fail "Response didn't have access_token" if access_token.blank?
      access_token
    end
  end
end
