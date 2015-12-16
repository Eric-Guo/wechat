require 'rest_client'

module Wechat
  class Client
    attr_reader :base, :verify_ssl

    def initialize(base, skip_verify_ssl)
      @base = base
      @verify_ssl = !skip_verify_ssl
    end

    def get(path, header = {})
      request(path, header) do |url, header|
        if verify_ssl
          RestClient::Request.execute(method: :get, url: url, headers: header)
        else
          RestClient::Request.execute(method: :get, url: url, headers: header, verify_ssl: OpenSSL::SSL::VERIFY_NONE)
        end
      end
    end

    def post(path, payload, header = {})
      request(path, header) do |url, header|
        if verify_ssl
          RestClient::Request.execute(method: :post, url: url, payload: payload, headers: header)
        else
          RestClient::Request.execute(method: :post, url: url, payload: payload, headers: header, verify_ssl: OpenSSL::SSL::VERIFY_NONE)
        end
      end
    end

    def request(path, header = {}, &block)
      url = "#{header.delete(:base) || base}#{path}"
      as = header.delete(:as)
      header.merge!(accept: :json)
      response = yield(url, header)

      fail "Request not OK, response code #{response.code}" if response.code != 200
      parse_response(response, as || :json) do |parse_as, data|
        break data unless parse_as == :json && data['errcode'].present?

        case data['errcode']
        when 0 # for request didn't expect results
          data
        # 42001: access_token超时
        # 40014: 不合法的access_token
        # 40001, invalid credential, access_token is invalid or not latest hint
        # 48001, api unauthorized hint, for qrcode creation # 71
        when 42001, 40014, 40001, 48001
          fail AccessTokenExpiredError
        else
          fail ResponseError.new(data['errcode'], data['errmsg'])
        end
      end
    end

    private

    def parse_response(response, as)
      content_type = response.headers[:content_type]
      parse_as = {
        %r{^application\/json} => :json,
        %r{^image\/.*} => :file
      }.each_with_object([]) { |match, memo| memo << match[1] if content_type =~ match[0] }.first || as || :text

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
