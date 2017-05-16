require 'spec_helper'

RSpec.describe Wechat::ApiLoader do

  it 'should config' do
    expect(Wechat.config.token).to eq 'token'
    expect(Wechat.config(:default).token).to eq 'token'
  end

  describe "should support multiple accounts config" do
    before(:all) do
      Wechat::ApiLoader.class_eval { @configs = nil }
      ENV['WECHAT_CONF_FILE'] = File.join(Dir.getwd, 'spec/dummy/config/dummy_wechat.yml')
    end

    after(:all) do
      Wechat::ApiLoader.class_eval { @configs = nil }
      ENV['WECHAT_CONF_FILE'] = nil
    end

    it 'should load config file' do
      expect(Wechat.config.appid).to eq 'my_appid'
      expect(Wechat.config.secret).to eq 'my_secret'
      expect(Wechat.config(:default).appid).to eq 'my_appid'
      expect(Wechat.config(:default).secret).to eq 'my_secret'

      expect(Wechat.config(:wx2).appid).to eq 'my_appid2'
      expect(Wechat.config(:wx2).secret).to eq 'my_secret2'
    end

    it 'should create api for account' do
      default_api = Wechat::ApiLoader.with({})
      expect(default_api.access_token.appid).to eq 'my_appid'

      new_api = Wechat::ApiLoader.with account: :wx2, token: 'new_token2'
      expect(new_api.access_token.appid).to eq 'my_appid2'
    end
  end
end
