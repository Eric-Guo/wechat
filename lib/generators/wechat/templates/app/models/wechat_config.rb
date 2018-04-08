# Used by wechat gems, do not rename WechatConfig to other name,
# Feel free to inherit from other class like ActiveModel::Model
class WechatConfig < ActiveRecord::Base
  validates :account, presence: true, uniqueness: true
  validates :token, presence: true
  validates :access_token, presence: true
  validates :jsapi_ticket, presence: true
  validates :encoding_aes_key, presence: {if: :encrypt_mode?}

  validate :app_config_is_valid

  def get_hash
    hash = self.as_json
    hash.delete(:environment, :account, :created_at, :updated_at)
    hash
  end

  private

  def app_config_is_valid
    self[:appid].present? && self[:secret].present? ||                              # public account
      self[:corp].present? && self[:corpsecret].present? && self[:agentid].present? # corp account
  end
end
