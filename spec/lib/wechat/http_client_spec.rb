require 'spec_helper'

RSpec.describe Wechat::HttpClient do
  subject do
    Wechat::HttpClient.new('http://host/', Wechat::NetworkSetting.new(20, false, nil, nil, nil))
  end

  let(:response_params) do
    {
      headers: { 'content-type' => 'text/plain' },
      status: 200
    }
  end
  let(:response_404) { double '404', response_params.merge(status: 404) }
  let(:response_text) { double 'text', response_params.merge(body: 'some text') }
  let(:response_json) do
    double 'json', response_params.merge(body: { result: 'success' }.to_json,
                                         headers: { 'content-type' => 'application/json' })
  end
  let(:response_json_as_text_plain) do
    double 'json', response_params.merge(body: { result: 'success' }.to_json)
  end
  let(:response_xml) do
    double 'xml', response_params.merge(body: '<xml><result_code>SUCCESS</result_code></xml>',
                                        headers: { 'content-type' => 'text/html' })
  end
  let(:response_image) { double 'image', response_params.merge(body: 'image data', headers: { 'content-type' => 'image/gif' }) }

  describe '#get' do
    specify 'Will use http get method to request data' do
      response = double('response', status: 200, body: { result: 'success' }.to_json, headers: { 'content-type' => 'application/json' })
      allow(subject.httpx).to receive(:with).and_return(subject.httpx)
      allow(subject.httpx).to receive(:get).and_return(response)
      subject.get('token')
    end
  end

  describe '#post' do
    specify 'Will use http post method to request data' do
      response = double('response', status: 200, body: { result: 'success' }.to_json, headers: { 'content-type' => 'application/json' })
      allow(subject.httpx).to receive(:with).and_return(subject.httpx)
      allow(subject.httpx).to receive(:post).and_return(response)
      subject.post('token', 'some_data')
    end
  end

  describe '#request' do
    specify 'will add accept=>:json for request' do
      block = lambda do |url, headers|
        expect(url).to eq('http://host/token')
        expect(headers).to eq(params: { access_token: '1234' }, 'Accept' => 'application/json')
        response_json
      end

      subject.send(:request, 'token', params: { access_token: '1234' }, &block)
    end

    specify 'will add accept=>:xml for request' do
      block = lambda do |url, headers|
        expect(url).to eq('http://host/token')
        expect(headers).to eq(params: { access_token: '1234' }, 'Accept' => 'application/json')
        response_xml
      end

      return_hash_by_xml = subject.send(:request, 'token', params: { access_token: '1234' }, as: :xml, &block)
      expect(return_hash_by_xml).to include('xml' => { 'result_code' => 'SUCCESS' })
    end

    specify 'will use base option to construct url' do
      block = lambda do |url, _headers|
        expect(url).to eq('http://override/token')
        response_json
      end
      subject.send(:request, 'token', base: 'http://override/', &block)
    end

    specify 'will not pass as option for request' do
      block = lambda do |_url, headers|
        expect(headers[:as]).to be_nil
        response_json
      end
      subject.send(:request, 'token', as: :text, &block)
    end

    specify 'will raise error if response code is not 200' do
      expect { subject.send(:request, 'token') { response_404 } }.to raise_error
    end

    context 'parse response body' do
      specify 'will return response body for text response' do
        expect(subject.send(:request, 'text', as: :text) { response_text }).to eq(response_text.body)
      end

      specify 'will return response body as file for image' do
        expect(subject.send(:request, 'image') { response_image }).to be_a(Tempfile)
      end

      specify 'will return response body as file for audio' do
        response_audio = double 'audio', response_params.merge(body: 'stream', headers: { 'content-type' => 'audio/amr' })
        expect(subject.send(:request, 'media') { response_audio }).to be_a(Tempfile)
      end

      specify 'will return response body as file for speex' do
        response_speex = double 'speex', response_params.merge(body: 'stream', headers: { 'content-type' => 'voice/speex' })
        expect(subject.send(:request, 'media') { response_speex }).to be_a(Tempfile)
      end

      specify 'will return response body as file for unknown content_type' do
        response_stream = double 'image', response_params.merge(body: 'stream', headers: { 'content-type' => 'stream' })
        expect(subject.send(:request, 'image', as: :file) { response_stream }).to be_a(Tempfile)
      end
    end

    context 'parse content_type of text/plain' do
      specify 'will return response body as json for text/plain content_type' do
        expect(subject.send(:request, 'json') { response_json_as_text_plain }).to be_a(Hash)
      end

      specify 'raise ResponseError given response has error json with content_type of text/plain' do
        allow(response_json_as_text_plain).to receive(:body).and_return({ errcode: 40007, errmsg: 'invalid media_id' }.to_json)
        expect { subject.send(:request, 'media', as: :file) { response_json_as_text_plain } }.to raise_error(Wechat::ResponseError)
      end

      specify 'will fallback to user-specified format for not json' do
        allow(response_json_as_text_plain).to receive(:body).and_return('not a json string')
        expect(subject.send(:request, 'media', as: :file) { response_json_as_text_plain }).to be_a(Tempfile)
      end
    end

    context 'json error' do
      specify 'raise ResponseError given response has error json' do
        allow(response_json).to receive(:body).and_return({ errcode: 1106, errmsg: 'error message' }.to_json)
        expect { subject.send(:request, 'image', as: :file) { response_json } }.to raise_error(Wechat::ResponseError)
      end

      specify 'raise AccessTokenExpiredError given response has error json with errorcode 40014' do
        allow(response_json).to receive(:body).and_return({ errcode: 40014, errmsg: 'error message' }.to_json)
        expect { subject.send(:request, 'image', as: :file) { response_json } }.to raise_error(Wechat::AccessTokenExpiredError)
      end
    end
  end
end
