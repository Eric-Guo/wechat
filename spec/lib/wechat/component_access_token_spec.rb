require 'spec_helper'

RSpec.describe Wechat::Token::ComponentAccessToken do
  let(:token_file) { Rails.root.join('component_access_token') }
  let(:ticket_file) { Rails.root.join('component_verify_ticket') }
  let(:token) { '12345' }
  let(:client) { double(:client) }

  subject do
    Wechat::Token::ComponentAccessToken.new(client, 'component_appid', 'component_appsecret', token_file, ticket_file, 'component_access_token')
  end

  before :each do
    allow(client).to receive(:get)
                         .with('api_component_token', params: {component_appid: 'component_appid',
                                                               component_appsecret: 'component_appsecret',
                                                               component_verify_ticket: 'component_verify_ticket'})
                         .and_return('component_access_token' => '12345', 'expires_in' => 7200)
    File.open(ticket_file, 'w') { |f| f.write({'verify_ticket' => 'component_verify_ticket', 'ticket_expires_in' => 12.hours.to_i, 'got_ticket_at' => Time.now.to_i}.to_json) }
  end

  after :each do
    File.delete(token_file) if File.exist?(token_file)
    File.delete(ticket_file) if File.exist?(ticket_file)
  end

  describe '#token' do
    specify 'read from file if access_token is not initialized' do
      File.open(token_file, 'w') { |f| f.write({'component_access_token' => '12345', 'token_expires_in' => 7200}.to_json) }
      expect(subject.token).to eq('12345')
    end

    specify "refresh access_token if token file didn't exist" do
      expect(File.exist? token_file).to be false
      expect(subject.token).to eq('12345')
      expect(File.exist? token_file).to be true
    end

    specify 'refresh access_token if token file is invalid' do
      File.open(token_file, 'w') { |f| f.write('rubbish') }
      expect(subject.token).to eq('12345')
    end

    specify 'raise exception if refresh failed' do
      allow(client).to receive(:get).and_raise('error')
      expect { subject.token }.to raise_error('error')
    end
  end

  describe '#refresh' do
    specify 'will set access_token' do
      expect(subject.refresh).to eq(token)
      expect(subject.access_token).to eq('12345')
    end

    specify "won't set access_token if request failed" do
      allow(client).to receive(:get).and_raise('error')

      expect { subject.refresh }.to raise_error('error')
      expect(subject.access_token).to be_nil
    end

    specify "won't set access_token if response value invalid" do
      allow(client).to receive(:get).and_return('rubbish')

      expect { subject.refresh }.to raise_error(Wechat::InvalidCredentialError)
      expect(subject.access_token).to be_nil
    end

    # it will be nil(content_length 0) if appid and secret is invalid
    specify "won't set access_token if response value is nil" do
      allow(client).to receive(:get).and_return(nil)

      expect { subject.refresh }.to raise_error(Wechat::InvalidCredentialError)
      expect(subject.access_token).to be_nil
    end
  end
end
