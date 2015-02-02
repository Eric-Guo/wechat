require 'openssl/cipher'
require 'securerandom'
require 'base64'

module Wechat
  module Cipher
    extend ActiveSupport::Concern

    BLOCK_SIZE = 32
    CIPHER = 'AES-256-CBC'

    def encrypt(plain, encoding_aes_key)
      cipher = OpenSSL::Cipher.new(CIPHER)
      cipher.encrypt

      cipher.padding = 0
      key_data = Base64.decode64(encoding_aes_key)
      cipher.key = key_data
      cipher.iv = key_data[0..16]

      cipher.update(encode_padding(plain)) + cipher.final
    end

    def decrypt(msg, encoding_aes_key)
      cipher = OpenSSL::Cipher.new(CIPHER)
      cipher.decrypt

      cipher.padding = 0
      key_data = Base64.decode64(encoding_aes_key)
      cipher.key = key_data
      cipher.iv = key_data[0..16]

      plain = cipher.update(msg) + cipher.final
      decode_padding(plain)
    end

    def pack
    end

    def unpack
    end


    private
    def encode_padding(data)
      length = data.length
      amount_to_pad = BLOCK_SIZE - (length % BLOCK_SIZE)
      amount_to_pad = BLOCK_SIZE if amount_to_pad == 0
      padding = ([amount_to_pad].pack('c') * amount_to_pad)
      data + padding
    end

    def decode_padding(plain)
      pad = plain.bytes[-1]
      # no padding
      pad = 0 if pad < 1 || pad > BLOCK_SIZE
      plain[0...(plain.length - pad)]
    end
  end
end
