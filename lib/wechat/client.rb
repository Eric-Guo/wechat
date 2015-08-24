require 'rest_client'

module Wechat
  class Client
    attr_reader :base

    def initialize(base)
      @base = base
    end

    def get(path, header = {}, verify_ssl = true)
      request(path, header) do |url, header|
        if verify_ssl
          RestClient.get(url, header)
        else
          RestClient::Request.execute(url: url, method: :get, headers: header, verify_ssl: OpenSSL::SSL::VERIFY_NONE)
        end
      end
    end

    def post(path, payload, header = {}, verify_ssl = true)
      request(path, header) do |url, header|
        if verify_ssl
          RestClient.post(url, payload, header)
        else
          RestClient::Request.execute(url: url, method: :post, payload: payload, headers: header, verify_ssl: OpenSSL::SSL::VERIFY_NONE)
        end
      end
    end

    def request(path, header = {}, &block)
      url = "#{header.delete(:base) || self.base}#{path}"
      as = header.delete(:as)
      header.merge!(:accept => :json)
      response = yield(url, header)

      raise "Request not OK, response code #{response.code}" if response.code != 200
      parse_response(response, as || :json) do |parse_as, data|
        break data unless parse_as == :json && data['errcode'].present?

        case data['errcode']
        when 0 # for request didn't expect results
          data
        when 42_001, 40_014 # 42001: access_token超时, 40014:不合法的access_token
          raise AccessTokenExpiredError
        else
          raise ResponseError.new(data['errcode'], data['errmsg'])
        end
      end
    end

    private

    def parse_response(response, as)
      content_type = response.headers[:content_type]
      parse_as = {
        /^application\/json/ => :json,
        /^image\/.*/ => :file
      }.inject([]){ |memo, match| memo << match[1] if content_type =~ match[0]; memo }.first || as || :text

      case parse_as
      when :file
        file = Tempfile.new('tmp')
        file.binmode
        file.write(response.body)
        file.close
        data = file

      when :json
        data = JSON.parse(response.body.gsub /[\u0000-\u001f]+/, '')

      else
        data = response.body
      end

      yield(parse_as, data)
    end
  end
end
