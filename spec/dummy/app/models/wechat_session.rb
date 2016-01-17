# Used by wechat gems, do not rename WechatSession to other name.
class WechatSession < ActiveRecord::Base
  validates :openid, presence: true, uniqueness: true

  def self.find_session(openid)
    find_or_initialize_by(openid: openid)
  end

  def save_session
    save!
  end

  def json_hash=(data)
    self.json_hash_raw = data.try :to_json
  end

  def json_hash
    json_hash_raw.blank? ? {} : JSON.parse(json_hash_raw).symbolize_keys
  end
end
