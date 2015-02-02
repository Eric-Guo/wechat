require 'spec_helper'

describe Wechat::Cipher do

  subject { Class.new.include(Wechat::Cipher) }

  it '#encode_padding' do
    result = subject.new.instance_eval { encode_padding('abcd') }
    expect(result.length).to eq Wechat::Cipher::BLOCK_SIZE
    expect(result.bytes[-1]).to eq (Wechat::Cipher::BLOCK_SIZE - 4)
  end

  it '#decode_padding' do
    result = subject.new.instance_eval { decode_padding("abcd\x3\x3\x3") }
    expect(result).to eq 'abcd'
  end

  it '#encrypt & #decrypt' do
    key = SecureRandom.base64(32)
    plain_text = 'hello world'
    encrypt_text = subject.new.instance_eval { encrypt(plain_text, key) }
    decrypt_text = subject.new.instance_eval { decrypt(encrypt_text, key) }

    expect(decrypt_text).to eq plain_text
  end

  it '#pack & #unpack' do
    content = '<xml>text</xml>'
    app_id = 'bravo_app'

    packed_text = subject.new.instance_eval { pack(content, app_id) }

    content2, app_id2 = subject.new.instance_eval { unpack(packed_text) }

    expect(content2).to eq content
    expect(app_id2).to eq app_id
  end

end
