require 'active_record'

module Wechat
  class WechatLog < ::ActiveRecord::Base
    def self.create_by_responder(req, res, session)
      create openid: req[:FromUserName], request_raw: req.try(:to_json), response_raw: res.try(:to_json), session_raw: session.to_json
    end

    def self.find_session(openid)
      select(:session_raw).where(openid: openid).last.try :session
    end

    %i(request response session).each do |name|
      define_method name do
        raw = send(:"#{name}_raw")
        raw.blank? ? {} : JSON.parse(raw).symbolize_keys
      end
    end
  end
end
