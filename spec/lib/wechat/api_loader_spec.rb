require 'spec_helper'

RSpec.describe Wechat::ApiLoader do
  before(:each) { Wechat::ApiLoader.class_eval { @configs = nil } }
  after(:each) { Wechat::ApiLoader.class_eval { @configs = nil } }

  it 'should get config from environment by default' do
    expect(Wechat.config.token).to eq 'token'
    expect(Wechat.config(:default).token).to eq 'token'

    default_configs = Wechat::ApiLoader.instance_variable_get(:@configs)
    expect(default_configs.keys).to eq [:default]
  end

  describe '#reload_config!' do
    before(:each) do
      ENV['WECHAT_APPID'] = 'appid'
    end
    after(:each) do
      ENV['WECHAT_APPID'] = 'appid'
    end

    it 'reloads configs' do
      # setup environment config
      ENV['WECHAT_APPID'] = 'app_id_1'
      # setup db config
      allow(WechatConfig).to receive(:get_all_configs).with('test').and_return({ test_account: { appid: 'test_app' } })

      expect(Wechat.config(:default).appid).to eq 'app_id_1'
      expect(Wechat.config(:test_account).appid).to eq 'test_app'

      # update environment config
      ENV['WECHAT_APPID'] = 'app_id_2'
      # update db config
      allow(WechatConfig).to receive(:get_all_configs).with('test').and_return({ new_test_account: { appid: 'new_test_app' } })

      Wechat::ApiLoader.reload_config!

      expect(Wechat.config(:default).appid).to eq 'app_id_2'
      expect(Wechat.config(:new_test_account).appid).to eq 'new_test_app'
    end
  end

  describe '#config_from_file' do
    before(:all) do
      ENV['WECHAT_CONF_FILE'] = File.join(Dir.getwd, 'spec/dummy/config/dummy_wechat.yml')
    end

    after(:all) do
      ENV['WECHAT_CONF_FILE'] = nil
    end

    it 'should load config file' do
      expect(Wechat.config.appid).to eq 'my_appid'
      expect(Wechat.config.secret).to eq 'my_secret'
      expect(Wechat.config(:default).appid).to eq 'my_appid'
      expect(Wechat.config(:default).secret).to eq 'my_secret'

      expect(Wechat.config(:wx2).appid).to eq 'my_appid2'
      expect(Wechat.config(:wx2).secret).to eq 'my_secret2'

      expect(Wechat.config(:component).component_appid).to eq 'component_appid'
      expect(Wechat.config(:component).encoding_aes_key).to eq 'component_encoding_aes_key'
    end

    it 'should create api for account' do
      default_api = Wechat::ApiLoader.with({})
      expect(default_api.access_token.appid).to eq 'my_appid'

      new_api = Wechat::ApiLoader.with account: :wx2, token: 'new_token2'
      expect(new_api.access_token.appid).to eq 'my_appid2'
    end

    it 'should create component api for component account' do
      component_api = Wechat::ApiLoader.with account: :component
      expect(component_api.access_token.appid).to eq 'component_appid'
    end
  end

  describe '#config_from_environment' do
    it 'loads default config from environment' do
      # arguments set in spec_helper.rb
      expect(Wechat.config(:default).appid).to eq 'appid'
      expect(Wechat.config(:default).secret).to eq 'secret'
      expect(Wechat.config(:default).token).to eq 'token'
    end
  end

  describe '#config_from_db' do
    it 'includes db config for current environment' do
      allow(WechatConfig).to receive(:get_all_configs).with('development').and_return({
          dev_account_1: { appid: 'dev_app_1' },
          dev_account_2: { appid: 'dev_app_2' }
      })
      expect(WechatConfig).to receive(:get_all_configs).with('test').and_return({
          test_account_1: { appid: 'test_app_1' },
          test_account_2: { appid: 'test_app_1' }
      })

      Wechat.config
      expect(Wechat::ApiLoader.instance_variable_get(:@configs).keys).to match_array [:default, :test_account_1, :test_account_2]
      expect(Wechat.config(:default).appid).to eq 'appid'
      expect(Wechat.config(:test_account_1).appid).to eq 'test_app_1'
      expect(Wechat.config(:test_account_2).appid).to eq 'test_app_1'
    end

    context 'when both file and db config exist' do
      before(:each) do
        ENV['WECHAT_CONF_FILE'] = File.join(Dir.getwd, 'spec/dummy/config/dummy_wechat.yml')
      end
      after(:each) do
        ENV['WECHAT_CONF_FILE'] = nil
      end

      it 'includes configs from both file and db' do
        expect(WechatConfig).to receive(:get_all_configs).with('test').and_return({
            test_account_1: { appid: 'test_app_1' },
            test_account_2: { appid: 'test_app_1' }
        })

        Wechat.config
        expect(Wechat::ApiLoader.instance_variable_get(:@configs).keys).to match_array [:default, :wx2, :component, :test_account_1, :test_account_2]
        expect(Wechat.config(:default).appid).to eq 'my_appid'
        expect(Wechat.config(:wx2).appid).to eq 'my_appid2'
        expect(Wechat.config(:test_account_1).appid).to eq 'test_app_1'
        expect(Wechat.config(:test_account_2).appid).to eq 'test_app_1'
      end

      it 'contains db config if file config is overridden' do
        expect(WechatConfig).to receive(:get_all_configs).with('test').and_return({
            wx2: { appid: 'overridden_wx2_app_id' }
        })

        Wechat.config
        expect(Wechat::ApiLoader.instance_variable_get(:@configs).keys).to match_array [:default, :wx2, :component]
        expect(Wechat.config(:wx2).appid).to eq 'overridden_wx2_app_id'
      end
    end
  end

end
