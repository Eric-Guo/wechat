# Used by wechat gems, do not rename WechatSession to other name.
class WechatSession < ActiveRecord::Base
  validates :openid, presence: true, uniqueness: true
  serialize :hash_store, Hash

  def self.find_or_initialize_session(from_user_openid, _to_app_openid)
    find_or_initialize_by(openid: from_user_openid)
  end

  def save_session
    save!
  end
end
