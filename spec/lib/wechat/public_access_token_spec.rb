require 'spec_helper'

RSpec.describe Wechat::Token::PublicAccessToken do
  let(:token_file) { Rails.root.join('access_token') }
  let(:token) { '12345' }
  let(:client) { double(:client) }
  let(:record) { OpenStruct.new(access_token: '123', token_expires_in: '7200', got_token_at: '2022-12-19 17:34:11 +0900') }
  let(:time) { Time.zone.parse('2022-12-19T15:00:00+0800') }

  subject :file_based_subject do
    Wechat::Token::PublicAccessToken.new(client, 'appid', 'secret', token_file)
  end
  subject :record_based_subject do
    Wechat::Token::PublicAccessToken.new(client, 'appid', 'secret', token_file, record)
  end

  before :each do
    allow(client).to receive(:get)
      .with('token', params: { grant_type: 'client_credential',
                               appid: 'appid',
                               secret: 'secret' }).and_return('access_token' => '12345', 'expires_in' => 7200)
    allow(record).to receive(:save).and_return(true)
  end

  after :each do
    File.delete(token_file) if File.exist?(token_file)
  end

  describe '#token' do
    specify 'read from file if access_token is not initialized' do
      File.open(token_file, 'w') { |f| f.write({ 'access_token' => '12345', 'expires_in' => 7200 }.to_json) }
      expect(file_based_subject.token).to eq('12345')
    end

    specify 'read from attributes if access_token is not initialized' do
      File.open(token_file, 'w') { |f| f.write({ 'access_token' => '12345', 'expires_in' => 7200 }.to_json) }
      expect(record_based_subject.token).to eq(token)
    end

    specify "refresh access_token if token file didn't exist" do
      expect(File.exist? token_file).to be false
      expect(file_based_subject.token).to eq('12345')
      expect(File.exist? token_file).to be true
    end

    specify 'refresh access_token if token file is invalid' do
      File.open(token_file, 'w') { |f| f.write('rubbish') }
      expect(file_based_subject.token).to eq('12345')
    end

    specify 'raise exception if refresh failed' do
      allow(client).to receive(:get).and_raise('error')
      expect { file_based_subject.token }.to raise_error('error')
      expect { record_based_subject.token }.to raise_error('error')
    end
  end

  describe '#refresh' do
    specify 'will set access_token' do
      expect(file_based_subject.refresh).to eq(token)
      expect(file_based_subject.access_token).to eq('12345')
    end

    specify 'will set access_token, token_life_in_seconds, got_token_at' do
      allow(Time).to receive(:now).and_return(time)
      expect(record_based_subject.refresh).to eq(token)
      expect(record_based_subject.token).to eq('12345')
      expect(record_based_subject.access_token).to eq('12345')
      expect(record_based_subject.token_life_in_seconds).to eq(7200)
      expect(record_based_subject.got_token_at).to eq(time.to_i)
    end

    specify "won't set access_token if request failed" do
      allow(client).to receive(:get).and_raise('error')

      expect { file_based_subject.refresh }.to raise_error('error')
      expect(file_based_subject.access_token).to be_nil

      expect { record_based_subject.refresh }.to raise_error('error')
      expect(record_based_subject.access_token).to be_nil
    end

    specify "won't set access_token if response value invalid" do
      allow(client).to receive(:get).and_return('rubbish')

      expect { file_based_subject.refresh }.to raise_error(Wechat::InvalidCredentialError)
      expect(file_based_subject.access_token).to be_nil

      expect { record_based_subject.refresh }.to raise_error(Wechat::InvalidCredentialError)
      expect(record_based_subject.access_token).to be_nil
    end

    # it will be nil(content_length 0) if appid and secret is invalid
    specify "won't set access_token if response value is nil" do
      allow(client).to receive(:get).and_return(nil)

      expect { file_based_subject.refresh }.to raise_error(Wechat::InvalidCredentialError)
      expect(file_based_subject.access_token).to be_nil

      expect { record_based_subject.refresh }.to raise_error(Wechat::InvalidCredentialError)
      expect(record_based_subject.access_token).to be_nil
    end
  end
end
