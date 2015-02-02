module Wechat
  module Cipher
    extend ActiveSupport::Concern

    BLOCK_SIZE = 32

    def encrypt(plain, key)
    end

    def decrypt(msg, key)
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
