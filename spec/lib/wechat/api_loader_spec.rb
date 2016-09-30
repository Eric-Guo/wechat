require 'spec_helper'

RSpec.describe Wechat::ApiLoader do

  it 'should config' do
    expect(Wechat.config.token).to eq 'token'
    expect(Wechat.config(:default).token).to eq 'token'
  end

  it 'should load config file' do
    clear_wechat_configs
    ENV['WECHAT_CONF_FILE'] = File.join(Dir.getwd, 'spec/dummy/config/dummy_wechat.yml')

    expect(Wechat.config.appid).to eq 'my_appid'
    expect(Wechat.config.secret).to eq 'my_secret'
    expect(Wechat.config(:default).appid).to eq 'my_appid'
    expect(Wechat.config(:default).secret).to eq 'my_secret'

    expect(Wechat.config(:wx2).appid).to eq 'my_appid2'
    expect(Wechat.config(:wx2).secret).to eq 'my_secret2'

    clear_wechat_configs
    ENV['WECHAT_CONF_FILE'] = nil
  end

  it 'should create api for account' do
    clear_wechat_configs
    ENV['WECHAT_CONF_FILE'] = File.join(Dir.getwd, 'spec/dummy/config/dummy_wechat.yml')

    default_api = Wechat::ApiLoader.with({})
    expect(default_api.access_token.appid).to eq 'my_appid'

    new_api = Wechat::ApiLoader.with account: :wx2, token: 'new_token2'
    expect(new_api.access_token.appid).to eq 'my_appid2'

    clear_wechat_configs
    ENV['WECHAT_CONF_FILE'] = nil
  end

  def clear_wechat_configs
    Wechat::ApiLoader.class_eval do
      @configs = nil
    end
  end
end
