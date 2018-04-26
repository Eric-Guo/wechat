require 'openssl/cipher'
require 'base64'
require 'json'

module Wechat
  class Decryptor < Struct.new(:encrypted_data, :session_key, :iv, :cipher_type)
    CIPHER = 'AES-128-CBC'.freeze

    def decrypt
      cipher_type = cipher_type || CIPHER
      cipher      = OpenSSL::Cipher.new(cipher_type)
      cipher.decrypt

      cipher.key     = Base64.decode64(session_key)
      cipher.iv      = Base64.decode64(iv)
      decrypted_data = Base64.decode64(encrypted_data)
      JSON.parse(cipher.update(decrypted_data) + cipher.final)
    rescue Exception => e
      { 'errcode': 41003, 'errmsg': e.massage }
    end
  end
end
