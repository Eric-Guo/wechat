# Used by wechat gems, do not rename WechatConfig to other name,
# Feel free to inherit from other class like ActiveModel::Model
class WechatConfig < ActiveRecord::Base
  validates :account, presence: true, uniqueness: true
  validates :token, presence: true
  validates :access_token, presence: true
  validates :jsapi_ticket, presence: true
  validates :encoding_aes_key, presence: {if: :encrypt_mode?}

  validate :app_config_is_valid

  private

  def app_config_is_valid
    if !self[:appid].blank?
      # public account
      !self[:secret].blank?
    else
      # corp account
      !self[:corp].blank? && !self[:corpsecret].blank? && !self[:agentid].blank?
    end
  end
end
