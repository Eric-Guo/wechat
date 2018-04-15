# Used by wechat gems, do not rename WechatConfig to other name,
# Feel free to inherit from other class like ActiveModel::Model
class WechatConfig < ActiveRecord::Base
  validates :environment, presence: true
  validates :account, presence: true, uniqueness: { scope: [:environment] }
  validates :token, presence: true
  validates :access_token, presence: true
  validates :jsapi_ticket, presence: true
  validates :encoding_aes_key, presence: { if: :encrypt_mode? }

  validate :app_config_is_valid

  ATTRIBUTES_TO_REMOVE = %w(environment account created_at updated_at enabled)

  def self.get_all_configs(environment)
    WechatConfig.where(environment: environment, enabled: true).inject({}) do |hash, config|
      hash[config.account] = config.build_config_hash
      hash
    end
  end

  def build_config_hash
    self.as_json(except: ATTRIBUTES_TO_REMOVE)
  end

  private

  def app_config_is_valid
    if self[:appid].present?
      # public account
      if self[:secret].blank?
        errors.add(:secret, 'cannot be nil when appid is set')
      end
    elsif self[:corpid].present?
      # corp account
      if self[:corpsecret].blank?
        errors.add(:corpsecret, 'cannot be nil when corpid is set')
      end
      if self[:agentid].blank?
        errors.add(:agentid, 'cannot be nil when corpid is set')
      end
    else
      errors[:base] << 'Either appid or corpid must be set'
    end
  end
end
