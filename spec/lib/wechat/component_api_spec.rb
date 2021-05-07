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
      response_result = {errcode: 0, errmsg: "ok"}

      expect(subject.client).to receive(:post)
                                    .with("api_start_push_ticket", {component_appid: "component_appid", component_secret: "component_secret"}.to_json,
                                          base: Wechat::Api::COMPONENT_API_BASE).and_return(response_result)

      expect(subject.start_push_ticket).to eq response_result
    end
  end

  describe "get pre-auth-code" do
    specify "will get pre-auth-code" do
      response_result = {
          pre_auth_code: 'Cx_Dk6qiBE0Dmx4EmlT3oRfArPvwSQ-oa3NL_fwHM7VI08r52wazoZX2Rhpz1dEw',
          expires_in: 600
      }

      expect(subject.client).to receive(:get)
                                    .with('api_create_preauthcode', params: {
                                        component_appid: 'component_appid', component_access_token: 'component_access_token'
                                    })
                                    .and_return(response_result)
      expect(subject.get_pre_auth_code).to eq response_result
    end
  end

  describe "get auth url" do
    specify "get auth url" do
      response_result = {
          pre_auth_code: 'code_test',
          expires_in: 600
      }

      expect(subject.client).to receive(:get)
                                    .with('api_create_preauthcode', params: {
                                        component_appid: 'component_appid', component_access_token: 'component_access_token'
                                    })
                                    .and_return(response_result)
      result = subject.get_auth_url('http://example.com/?a=\11\15')
      expect(result).to match (/code_test/)
    end
  end
end
