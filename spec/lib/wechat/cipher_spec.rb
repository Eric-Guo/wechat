require 'spec_helper'

describe Wechat::Cipher do

  it '#encode_padding' do
    result = Class.new.include(Wechat::Cipher).new.instance_eval { encode_padding('abcd') }
    expect(result.length).to eq Wechat::Cipher::BLOCK_SIZE
    expect(result.bytes[-1]).to eq (Wechat::Cipher::BLOCK_SIZE - 4)
  end

  it '#decode_padding' do
    result = Class.new.include(Wechat::Cipher).new.instance_eval { decode_padding("abcd\x3\x3\x3") }
    expect(result).to eq 'abcd'
  end

end
