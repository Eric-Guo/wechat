module Wechat
  class AccessToken
    attr_reader :client, :appid, :secret, :token_file, :token_data

    def initialize(client, appid, secret, token_file)
      @appid = appid
      @secret = secret
      @client = client
      @token_file = token_file
    end

    def token
      begin
        @token_data ||= JSON.parse(File.read(token_file))
        created_at = token_data["created_at"].to_i
        expires_in = token_data["expires_in"].to_i
        if Time.now.to_i - created_at >= expires_in - 3*60
          raise "token_data may be expired"
        end
      rescue
        self.refresh
      end
      return valid_token(@token_data)
    end

    def refresh
      data = client.get("token", params:{grant_type: "client_credential", appid: appid, secret: secret})
      data.merge!(created_at: Time.now.to_i)
      File.open(token_file, 'w'){|f| f.write(data.to_json)} if valid_token(data)
      return @token_data = data
    end

    private
    def valid_token token_data
      access_token = token_data["access_token"]
      raise "Response didn't have access_token" if  access_token.blank?
      return access_token
    end

  end
end
