require 'spec_helper'

RSpec.describe WechatConfig, type: :model do
  subject(:test_account) {
    described_class.new(
        environment: 'test',
        account: 'account',
        account_type: 'mp',
        enabled: true,

        appid: 'appid',
        secret: 'secret',

        corpid: 'corpid',
        corpsecret: 'corpsecret',
        agentid: 10,

        encrypt_mode: true,
        encoding_aes_key: 'aes_key',

        token: 'token',
        access_token: 'tmp/test/account/access_token',
        jsapi_ticket: 'tmp/test/account/jsapi_ticket',
        skip_verify_ssl: true,
        timeout: 30,
        trusted_domain_fullname: 'http://dev_domain',
    )
  }

  describe '#valid?' do
    it 'is valid with valid attributes' do
      expect(test_account).to be_valid
    end

    it 'is not valid without environment' do
      test_account.environment = nil
      expect(test_account).to_not be_valid
    end

    it 'is not valid without account' do
      test_account.account = nil
      expect(test_account).to_not be_valid
    end

    it 'is not valid without token' do
      test_account.token = nil
      expect(test_account).to_not be_valid
    end

    it 'is not valid without access_token' do
      test_account.access_token = nil
      expect(test_account).to_not be_valid
    end

    it 'is not valid without jsapi_ticket' do
      test_account.jsapi_ticket = nil
      expect(test_account).to_not be_valid
    end

    context 'when encoding_mode is true' do
      let(:encrypted_account) { test_account.encrypt_mode = true; test_account }

      it 'is not valid without encoding_aes_key' do
        encrypted_account.encoding_aes_key = nil
        expect(encrypted_account).to_not be_valid
      end
    end

    context 'when encoding_mode is false' do
      let(:unencrypted_account) { test_account.encrypt_mode = false; test_account }

      it 'is valid without encoding_aes_key' do
        unencrypted_account.encoding_aes_key = nil
        expect(unencrypted_account).to be_valid
      end
    end

    context 'within single environment' do
      before(:all) { WechatConfig.delete_all }
      after(:all) { WechatConfig.delete_all }

      it 'is not valid to have same account name' do
        test_account_1 = test_account.dup
        expect(test_account_1.save).to be_truthy
        expect(test_account_1).to be_valid

        test_account_2 = test_account.dup
        expect(test_account_2.save).to_not be_truthy
        expect(test_account_2).to_not be_valid
      end
    end

    context 'among different environments' do
      before(:all) { WechatConfig.delete_all }
      after(:all) { WechatConfig.delete_all }

      it 'is valid to have same account name' do
        production_account = test_account.dup
        production_account.environment = 'production'
        expect(production_account.save).to be_truthy
        expect(production_account).to be_valid

        development_account = test_account.dup
        development_account.environment = 'development'
        expect(development_account.save).to be_truthy
        expect(development_account).to be_valid
      end
    end

    it 'is not valid without appid or corpid' do
      test_account.appid = nil
      test_account.corpid = nil
      expect(test_account).to_not be_valid
    end

    context 'when public app is set' do
      let(:public_account) { test_account.corpid = nil; test_account }

      it 'is valid with valid attributes' do
        expect(public_account).to be_valid
      end

      it 'is not valid without secret' do
        public_account.secret = nil
        expect(public_account).to_not be_valid
      end
    end

    context 'when corp app is set' do
      let(:corp_account) { test_account.appid = nil; test_account }

      it 'is valid with valid attributes' do
        expect(corp_account).to be_valid
      end

      it 'is not valid without corpsecret' do
        corp_account.corpsecret = nil
        expect(corp_account).to_not be_valid
      end

      it 'is not valid without agentid' do
        corp_account.agentid = nil
        expect(corp_account).to_not be_valid
      end
    end
  end

  describe '#build_config_hash' do
    let(:config_hash) { test_account.build_config_hash }

    it 'includes relevant attributes' do
      (WechatConfig.column_names - WechatConfig::ATTRIBUTES_TO_REMOVE).each do |attribute|
        expect(config_hash).to have_key attribute
      end
    end

    it 'does not include irrelevant attributes' do
      WechatConfig::ATTRIBUTES_TO_REMOVE.each do |attribute|
        expect(config_hash).to_not have_key attribute
      end
    end

    it 'has account_type set to "mp"' do
      expect(test_account.account_type).to eq 'mp'
    end
  end

  describe '#get_all_configs' do
    before(:each) do
      WechatConfig.delete_all
      create_account('development', 'dev_account_1')
      create_account('development', 'dev_account_2')
      create_account('test', 'test_account_1')
      create_account('test', 'test_account_2')
    end
    after(:each) { WechatConfig.delete_all }

    it 'returns empty hash when no config is specified for an environment' do
      configs = WechatConfig.get_all_configs('production')
      expect(configs).to be_empty
    end

    it 'includes all configs for specified environment' do
      configs = WechatConfig.get_all_configs('development')
      expect(configs.keys).to eq %w(dev_account_1 dev_account_2)

      configs = WechatConfig.get_all_configs('test')
      expect(configs.keys).to eq %w(test_account_1 test_account_2)
    end

    it 'does not include disabled config' do
      account = create_account('test', 'enabled_account')
      configs = WechatConfig.get_all_configs('test')
      expect(configs.keys).to eq %w(test_account_1 test_account_2 enabled_account)

      account.account = 'disabled_account'
      account.enabled = false
      account.save

      configs = WechatConfig.get_all_configs('test')
      expect(configs.keys).to eq %w(test_account_1 test_account_2)
    end

    private
    def create_account(environment, account_name)
      account = test_account.dup
      account.environment = environment
      account.account = account_name
      account.save
      account
    end
  end
end
