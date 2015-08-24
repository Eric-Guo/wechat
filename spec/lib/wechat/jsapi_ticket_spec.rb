require 'spec_helper'

describe Wechat::JsapiTicket do
  let(:ticket_content){
    {
      errcode: 0,
      errmsg: "ok",
      ticket: "bxLdikRXVbTPdHSM05e5u5sUoXNKd8-41ZO3MhKoyN5OfkWITDGgnr2fwJ0m9E8NYzWKVZvdVtaUgWvsdshFKA",
      expires_in: 7200
    }
  }
  let(:jsapi_ticket_file){Rails.root.join("tmp/jsapi_ticket_file")}
  let(:client){ double(:client) }
  let(:access_token){ double(:access_token) }
  let(:token_content){ {access_token: "12345", expires_in: 7200} }

  subject do
    Wechat::JsapiTicket.new(client, access_token, jsapi_ticket_file)
  end

  before :each do
    allow(client).to receive(:get).with("ticket/getticket", params: {
      type: "jsapi",
      access_token: token_content[:access_token]
    }).and_return(ticket_content)

    allow(access_token).to receive(:token).and_return(token_content[:access_token])
  end

  after :each do
    File.delete(jsapi_ticket_file) if File.exist?(jsapi_ticket_file)
  end

  describe "#ticket" do
    specify "read from file if jsapi_ticket_file is not initialized" do
      File.open(jsapi_ticket_file, 'w'){|f| f.write(ticket_content.to_json)}
      expect(subject.ticket).to eq(ticket_content[:ticket])
    end
  end

  describe "#refresh" do
    specify "will set jsapi_ticket_data" do
      expect(subject.refresh).to eq(ticket_content)
      expect(subject.jsapi_ticket_data).to eq(ticket_content)
    end
  end
  describe "#signature" do
    specify "will get signature" do
      url = 'http://www.baidu.com?q=ming'
      expect(subject.signature(url)[:url]).to eq(url)
    end
  end
end
