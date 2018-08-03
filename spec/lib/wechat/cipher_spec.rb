require 'spec_helper'

RSpec.describe Wechat::Cipher do
  subject { Class.new.send(:include, Wechat::Cipher) }

  it '#encode_padding' do
    result = subject.new.instance_eval { encode_padding('abcd') }
    expect(result.length).to eq Wechat::Cipher::BLOCK_SIZE
    expect(result.bytes[-1]).to eq Wechat::Cipher::BLOCK_SIZE - 4
  end

  it '#decode_padding' do
    result = subject.new.instance_eval { decode_padding("abcd\x3\x3\x3") }
    expect(result).to eq 'abcd'
  end

  it '#encrypt & #decrypt short' do
    key = SecureRandom.base64(32)
    plain_text = 'hello world'
    encrypt_text = subject.new.instance_eval { encrypt(encode_padding(plain_text), key) }
    decrypt_text = subject.new.instance_eval { decrypt(encrypt_text, key) }

    expect(decrypt_text).to eq plain_text
  end

  it '#encrypt & #decrypt long' do
    key = SecureRandom.base64(32)
    plain_text = <<SHAKESPEARE
Shall I compare thee to a summer's day?
Thou art more lovely and more temperate:
Rough winds do shake the darling buds of May,
And summer's lease hath all too short a date:
Sometime too hot the eye of heaven shines,
And often is his gold complexion dimm'd;
And every fair from fair sometime declines,
By chance, or nature's changing course, untrimm'd;
But thy eternal summer shall not fade
Nor lose possession of that fair thou ow'st;
Nor shall Death brag thou wander'st in his shade,
When in eternal lines to time thou grow'st;
So long as men can breathe or eyes can see,
So long lives this, and this gives life to thee.
SHAKESPEARE

    encrypt_text = subject.new.instance_eval { encrypt(encode_padding(plain_text), key) }
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
