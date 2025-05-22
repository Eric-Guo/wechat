# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Wechat::ApiConfig do
  describe '#initialize' do
    let(:appid) { 'test_appid' }
    let(:secret) { 'test_secret' }
    let(:token_file) { '/path/to/token_file' }
    let(:jsapi_ticket_file) { '/path/to/jsapi_ticket_file' }
    # Create a dummy NetworkSetting object or mock it if it's complex to instantiate
    let(:network_setting) { Wechat::NetworkSetting.new(20, false, nil, nil, nil) }

    subject do
      Wechat::ApiConfig.new(appid, secret, token_file, jsapi_ticket_file, network_setting)
    end

    it 'is initialized with correct appid' do
      expect(subject.appid).to eq(appid)
    end

    it 'is initialized with correct secret' do
      expect(subject.secret).to eq(secret)
    end

    it 'is initialized with correct token_file' do
      expect(subject.token_file).to eq(token_file)
    end

    it 'is initialized with correct jsapi_ticket_file' do
      expect(subject.jsapi_ticket_file).to eq(jsapi_ticket_file)
    end

    it 'is initialized with correct network_setting' do
      expect(subject.network_setting).to eq(network_setting)
    end
  end
end
