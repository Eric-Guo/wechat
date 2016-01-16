require 'active_record'

module Wechat
  class WechatSession < ActiveRecord::Base
    def self.find_session(openid)
      select(:session_raw).where(openid: openid).last.try :session
    end

    def self.update_session(openid, data)
      session = find_or_initialize_by openid: openid
      session.session = data
      session.save
    end

    def session=(data)
      self[:session_raw] = data.try :to_json
    end

    def session
      session_raw.blank? ? {} : JSON.parse(session_raw).symbolize_keys
    end
  end
end
