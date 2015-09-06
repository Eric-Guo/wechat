module Wechat
  module Signature
    def self.hexdigest(token, timestamp, nonce, msg_encrypt)
      array = [token, timestamp, nonce]
      array << msg_encrypt unless msg_encrypt.nil?
      dev_msg_signature = array.compact.collect(&:to_s).sort.join
      Digest::SHA1.hexdigest(dev_msg_signature)
    end
  end
end
