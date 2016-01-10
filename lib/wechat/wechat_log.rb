require 'active_record'

module Wechat
  class WechatLog < ::ActiveRecord::Base
    def self.create_by_responder(req, res, session)
      create openid: req[:FromUserName], request_raw: req.try(:to_json), response_raw: res.try(:to_json), session_raw: session.to_json
    end

    def request
      Hash.from_json request_raw
    end

    def response
      Hash.from_json response_raw
    end

    def session
      Hash.from_json session_raw
    end
  end
end
