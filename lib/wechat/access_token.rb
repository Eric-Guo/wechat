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
      rescue
        self.refresh
      end
      return valid_token(@token_data)
    end

    def refresh
      data = client.get("token", params:{grant_type: "client_credential", appid: appid, secret: secret})
      File.open(token_file, 'w'){|f| f.write(data.to_s)} if valid_token(data)
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
