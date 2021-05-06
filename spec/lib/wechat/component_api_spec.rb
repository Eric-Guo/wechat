require "spec_helper"

RSpec.describe Wechat::ComponentApi do
  let(:component_token_file) { Rails.root.join("tmp/component_access_token") }
  let(:component_verify_ticket_file) { Rails.root.join("tmp/component_verify_ticket") }

  subject do
    Wechat::ComponentApi.new("component_appid", "component_secret", component_token_file, component_verify_ticket_file, 20, false)
  end

  before :each do
    allow(subject.access_token).to receive(:token).and_return("component_access_token")
    allow(subject.access_token).to receive(:component_verify_ticket).and_return("component_verify_ticket")
  end

  describe "#API_BASE" do
    specify "will get correct API_BASE" do
      expect(subject.client.base).to eq Wechat::Api::COMPONENT_API_BASE
    end
  end

  describe "start push ticket" do
    specify "will enable wechat component_verify_ticket push event" do
      response_result = { errcode: 0, errmsg: "ok" }

      expect(subject.client).to receive(:post)
                                  .with("api_start_push_ticket", { component_appid: "component_appid", component_secret: "component_secret" }.to_json,
                                        base: Wechat::Api::COMPONENT_API_BASE).and_return(response_result)

      expect(subject.start_push_ticket).to eq response_result
    end
  end
end
