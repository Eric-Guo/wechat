require 'spec_helper'

RSpec.describe WechatConfig, type: :model do
  subject(:test_account) {
    described_class.new(
        environment: 'test',
        account: 'account',
        token: 'token',

        appid: 'appid',
        secret: 'secret',

        corpid: 'corpid',
        corpsecret: 'corpsecret',
        agentid: 10,

        encrypt_mode: true,
        encoding_aes_key: 'aes_key',

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

  describe '#get_hash' do
    let(:config_hash) { test_account.get_hash }

    it 'should include relevant attributes' do
      (WechatConfig.column_names - WechatConfig::ATTRIBUTES_TO_REMOVE).each do |attribute|
        expect(config_hash).to have_key attribute
      end
    end

    it 'should not include irrelevant attributes' do
      WechatConfig::ATTRIBUTES_TO_REMOVE.each do |attribute|
        expect(config_hash).to_not have_key attribute
      end
    end
  end
end
