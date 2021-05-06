# frozen_string_literal: true

require 'http'

module Wechat
  class HttpClient
    attr_reader :base, :ssl_context, :httprb

    def initialize(base, timeout, skip_verify_ssl)
      @base = base
      @httprb = if HTTP::VERSION.to_i >= 4
                  HTTP.timeout(write: timeout, connect: timeout, read: timeout)
                else
                  HTTP.timeout(:global, write: timeout, connect: timeout, read: timeout)
                end
      @ssl_context = OpenSSL::SSL::SSLContext.new
      @ssl_context.ssl_version = :TLSv1_2
      @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE if skip_verify_ssl
    end

    def get(path, get_header = {})
      request(path, get_header) do |url, header|
        params = header.delete(:params)
        httprb.headers(header).get(url, params: params, ssl_context: ssl_context)
      end
    end

    def post(path, payload, post_header = {})
      request(path, post_header) do |url, header|
        params = header.delete(:params)
        httprb.headers(header).post(url, params: params, body: payload, ssl_context: ssl_context)
      end
    end

    def post_file(path, file, post_header = {})
      request(path, post_header) do |url, header|
        params = header.delete(:params)
        form_file = file.is_a?(HTTP::FormData::File) ? file : HTTP::FormData::File.new(file)
        httprb.headers(header)
              .post(url, params: params,
                         form: { media: form_file,
                                 hack: 'X' }, # Existing here for http-form_data 1.0.1 handle single param improperly
                         ssl_context: ssl_context)
      end
    end

    private

    def request(path, header = {}, &_block)
      url_base = header.delete(:base) || base
      as = header.delete(:as)
      header['Accept'] ||= 'application/json'
      response = yield("#{url_base}#{path}", header)

      raise "Request not OK, response status #{response.status}" if response.status != 200

      parse_response(response, as || :json) do |parse_as, data|
        break data unless parse_as == :json && data['errcode'].present?
        case data['errcode']
        when 0 # for request didn't expect results
          data
        # 42001: access_token timeout
        # 40014: invalid access_token
        # 40001, invalid credential, access_token is invalid or not latest hint
        # 48001, api unauthorized hint, should not handle here # GH-230
        when 42001, 40014, 40001
          raise AccessTokenExpiredError
        # 40029, invalid code for mp # GH-225
        # 43004, require subscribe hint # GH-214
        else
          raise ResponseError.new(data['errcode'], data['errmsg'])
        end
      end
    end

    def parse_response(response, as_type)
      content_type = response.headers[:content_type]
      parse_as = {
        %r{^application/json} => :json,
        %r{^image/.*} => :file,
        %r{^audio/.*} => :file,
        %r{^voice/.*} => :file,
        %r{^text/html} => :xml,
        %r{^text/plain} => :probably_json
      }.each_with_object([]) { |match, memo| memo << match[1] if content_type =~ match[0] }.first || as_type || :text

      # try to parse response as json, fallback to user-specified format or text if failed
      if parse_as == :probably_json
        begin
          data = JSON.parse response.body.to_s.gsub(/[\u0000-\u001f]+/, '')
        rescue StandardError
          nil
        end
        return yield(:json, data) if data

        parse_as = as_type || :text
      end

      case parse_as
      when :file
        file = Tempfile.new('tmp')
        file.binmode
        file.write(response.body)
        file.close
        data = file

      when :json
        data = JSON.parse response.body.to_s.gsub(/[\u0000-\u001f]+/, '')
      when :xml
        data = Hash.from_xml(response.body.to_s)
      else
        data = response.body
      end

      yield(parse_as, data)
    end
  end
end
