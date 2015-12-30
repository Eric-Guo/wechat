module Wechat
  class AccessToken
    attr_reader :client, :appid, :secret, :token_file, :access_token, :token_life_in_seconds, :got_token_at

    def initialize(client, appid, secret, token_file)
      @appid = appid
      @secret = secret
      @client = client
      @token_file = token_file
      @random_generator = Random.new
    end

    def token
      begin
        read_token_from_file
        fail 'access_token may be expired' if remain_life_seconds < @random_generator.rand(30..3 * 60)
      rescue
        refresh
      end
      access_token
    end

    def refresh
      data = client.get('token', params: { grant_type: 'client_credential', appid: appid, secret: secret })
      write_token_to_file(data)
      read_token_from_file
      token_data
    end

    def token_data
      { 'access_token' => access_token, 'expires_in' => token_life_in_seconds, 'got_token_at' => got_token_at } if access_token
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
      File.write(token_file, token_hash.to_json)
    end

    def remain_life_seconds
      token_life_in_seconds - (Time.now.to_i - got_token_at)
    end
  end
end
