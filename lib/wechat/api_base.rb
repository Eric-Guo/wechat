module Wechat
  class ApiBase
    attr_reader :access_token, :client, :jsapi_ticket

    MP_BASE = 'https://mp.weixin.qq.com/cgi-bin/'

    def callbackip
      get 'getcallbackip'
    end

    def qrcode(ticket)
      client.get 'showqrcode', params: { ticket: ticket }, base: MP_BASE, as: :file
    end

    def media(media_id)
      get 'media/get', params: { media_id: media_id }, as: :file
    end

    def media_create(type, file)
      post 'media/upload', { upload: { media: file } }, params: { type: type }
    end

    protected

    def get(path, headers = {})
      with_access_token(headers[:params]) do |params|
        client.get path, headers.merge(params: params)
      end
    end

    def post(path, payload, headers = {})
      with_access_token(headers[:params]) do |params|
        client.post path, payload, headers.merge(params: params)
      end
    end

    def post_file(path, file, headers = {})
      with_access_token(headers[:params]) do |params|
        client.post_file path, file, headers.merge(params: params)
      end
    end

    def with_access_token(params = {}, tries = 2)
      params ||= {}
      yield(params.merge(access_token: access_token.token))
    rescue AccessTokenExpiredError
      access_token.refresh
      retry unless (tries -= 1).zero?
    end
  end
end
