require 'active_record'

module Wechat
  class WechatSession < ActiveRecord::Base
    def self.find_by_openid(from, to)
      where('("wechat_sessions"."from_openid" = ? AND "wechat_sessions"."to_openid" = ?) OR ("wechat_sessions"."from_openid" = ? AND "wechat_sessions"."to_openid" = ?)', from, to, to, from).first
    end

    def self.find_session(from, to)
      find_by_openid(from, to).try :session
    end

    def self.update_session(from, to, data)
      session = find_by_openid from, to
      session = new from_openid: from, to_openid: to if session.nil?
      session.session = data
      session.save
    end

    def session=(data)
      if ActiveRecord::Base.connection.adapter_name.downcase.to_sym == :postgresql
        self[:session_raw] = data.try :to_hash
      else
        self[:session_raw] = data.try :to_json
      end
    end

    def session
      return {} if session_raw.blank?
      raw = JSON.parse(session_raw)
      raw.symbolize_keys unless ActiveRecord::Base.connection.adapter_name.downcase.to_sym == :postgresql
    end
  end
end
