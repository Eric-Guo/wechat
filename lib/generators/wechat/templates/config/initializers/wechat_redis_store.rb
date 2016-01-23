module Wechat
  def self.redis
    # You can reuse existing redis connection and remove this method if require
    @redis ||= Redis.new # more options see https://github.com/redis/redis-rb#getting-started
  end

  module Token
    class AccessTokenBase
      def read_token
        JSON.parse(Wechat.redis.get('my_app_wechat_token'))
      end

      def write_token(token_hash)
        Wechat.redis.set 'my_app_wechat_token', token_hash.to_json
      end
    end
  end

  module Ticket
    class JsapiBase
      def read_ticket
        JSON.parse(Wechat.redis.get('my_app_wechat_ticket'))
      end

      def write_ticket(ticket_hash)
        Wechat.redis.set 'my_app_wechat_ticket', ticket_hash.to_json
      end
    end
  end
end
