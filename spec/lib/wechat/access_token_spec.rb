require 'spec_helper'

describe Wechat::AccessToken do
  let(:token_content){{"access_token" => "12345", "expires_in" => 7200}}
  let(:token_file){Rails.root.join("access_token")}
  let(:client){double(:client)}

  subject do
    Wechat::AccessToken.new(client, "appid", "secret", token_file)
  end

  before :each do
    allow(client).to receive(:get).with("token", params:{
      grant_type: "client_credential",
      appid: "appid",
      secret: "secret"}).and_return(token_content)
  end

  after :each do
    File.delete(token_file) if File.exist?(token_file)
  end

  describe "#token" do
    specify "read from file if access_token is not initialized" do
      File.open(token_file, 'w'){|f| f.write(token_content.to_json)}
      expect(subject.token).to eq("12345")
    end

    specify "refresh access_token if token file didn't exist" do
      expect(File.exist? token_file).to be false
      expect(subject.token).to eq("12345")
      expect(File.exist? token_file).to be true
    end

    specify "refresh access_token if token file is invalid" do
      File.open(token_file, 'w'){|f| f.write("rubbish")}
      expect(subject.token).to eq("12345")
    end

    specify "raise exception if refresh failed " do
      allow(client).to receive(:get).and_raise("error")
      expect{subject.token}.to raise_error("error")
    end
  end

  describe "#refresh" do
    specify "will set token_data" do
      expect(subject.refresh).to eq(token_content)
      expect(subject.token_data).to eq(token_content)
    end

    specify "won't set token_data if request failed" do
      allow(client).to receive(:get).and_raise("error")

      expect{subject.refresh}.to raise_error("error")
      expect(subject.token_data).to be_nil
    end

    specify "won't set token_data if response value invalid" do
      allow(client).to receive(:get).and_return("rubbish")

      expect{subject.refresh}.to raise_error
      expect(subject.token_data).to be_nil
    end

  end

end
