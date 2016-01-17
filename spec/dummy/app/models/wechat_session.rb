# Used by wechat gems, do not rename WechatSession to other name.
class WechatSession < ActiveRecord::Base
  validates :openid, presence: true, uniqueness: true

  def self.find_session(openid)
    select(:json_hash_raw).where(openid: openid).last.try :json_hash
  end

  def self.update_session(openid, data)
    session = find_or_initialize_by openid: openid
    session.json_hash = data
    session.save
  end

  def json_hash=(data)
    self.json_hash_raw = data.try :to_json
  end

  def json_hash
    json_hash_raw.blank? ? {} : JSON.parse(json_hash_raw).symbolize_keys
  end
end
