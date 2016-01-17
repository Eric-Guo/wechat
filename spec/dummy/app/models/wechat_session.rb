# Used by wechat gems, do not rename WechatSession to other name.
class WechatSession < ActiveRecord::Base
  validates :openid, presence: true, uniqueness: true
  serialize :hash_store, Hash

  def self.find_or_initialize_session(message_hash)
    find_or_initialize_by(openid: message_hash[:from_user_name])
  end

  def save_session
    save!
  end
end
