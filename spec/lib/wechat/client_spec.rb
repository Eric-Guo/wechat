require 'spec_helper'

describe Wechat::Client do
  subject do
    Wechat::Client.new("http://host/")
  end

  let(:response_params) do
    {
      headers:{content_type: "text/plain"},
      code: 200,
    }
  end
  let(:response_404){double "404", response_params.merge(code: 404)}
  let(:response_text){double "text", response_params.merge(body: "some text")}
  let(:response_json){double "json", response_params.merge(body: {result: "success"}.to_json, headers:{content_type: "application/json"})}
  let(:response_image){double "image", response_params.merge(body: "image data", headers:{content_type: "image/gif"})}

  describe "#get" do
    specify "Will use http get method to request data" do
      expect(RestClient).to receive(:get).with("http://host/token", accept: :json).and_return(response_json)
      subject.get("token")
    end
  end

  describe "#post" do
    specify "Will use http post method to request data" do
      expect(RestClient).to receive(:post).with("http://host/token", "some_data", accept: :json).and_return(response_json)
      subject.post("token", "some_data")
    end
  end

  describe "#request" do

    specify "will add accept=>:json for request" do
      block = ->(url, headers){
        expect(url).to eq("http://host/token")
        expect(headers).to eq(:params=>{access_token: "1234"}, :accept=>:json)
        response_json
      }

      subject.request("token", params:{access_token: "1234"}, &block)
    end

    specify "will use base option to construct url" do
      block = ->(url, headers){
        expect(url).to eq("http://override/token")
        response_json
      }
      subject.request("token", base:"http://override/", &block)
    end

    specify "will not pass as option for request" do
      block = ->(url, headers){
        expect(headers[:as]).to be_nil
        response_json
      }
      subject.request("token", as: :text, &block)
    end

    specify "will raise error if response code is not 200" do
      expect{subject.request("token"){response_404}}.to raise_error
    end

    context "parse response body" do
      specify "will return response body for text response" do
        expect(subject.request("text", as: :text){response_text}).to eq(response_text.body)
      end

      specify "will return response body as file for image" do
        expect(subject.request("image"){response_image}).to be_a(Tempfile)
      end

      specify "will return response body as file for unknown content_type" do
        response_stream = double "image", response_params.merge(body: "stream", headers:{content_type: "stream"})
        expect(subject.request("image", :as=>:file){response_stream}).to be_a(Tempfile)
      end
    end

    context "json error" do
      specify "raise ResponseError given response has error json" do
        allow(response_json).to receive(:body).and_return({errcode: 1106, errmsg: "error message"}.to_json)
        expect{subject.request("image", :as=>:file){response_json}}.to raise_error(Wechat::ResponseError)
      end

      specify "raise AccessTokenExpiredError given response has error json with errorcode 40014" do
        allow(response_json).to receive(:body).and_return({errcode: 40014, errmsg: "error message"}.to_json)
        expect{subject.request("image", :as=>:file){response_json}}.to raise_error(Wechat::AccessTokenExpiredError)
      end
    end

  end

end
