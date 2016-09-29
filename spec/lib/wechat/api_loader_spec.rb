require 'spec_helper'

RSpec.describe Wechat::ApiLoader do
  it 'should config' do
    expect(Wechat.config.token).to eq 'token'
  end
end
