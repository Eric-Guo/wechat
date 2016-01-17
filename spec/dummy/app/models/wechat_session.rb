# Used by wechat gems, do not rename WechatSession to other name.
class WechatSession < ActiveRecord::Base
  validates :openid, presence: true, uniqueness: true
  serialize :hash_store, Hash

  def self.find_or_initialize_session(request_message)
    find_or_initialize_by(openid: request_message[:from_user_name])
  end

  def save_session(response_message)
    save!
  end
end
