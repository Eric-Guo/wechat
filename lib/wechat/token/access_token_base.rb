# frozen_string_literal: true

module Wechat
  module Token
    class AccessTokenBase
      attr_reader :client, :appid, :secret, :token_file, :access_token, :token_life_in_seconds, :got_token_at, :record

      def initialize(client, appid, secret, token_file, record = nil)
        @appid = appid
        @secret = secret
        @client = client
        @token_file = token_file
        @record = record
        @random_generator = Random.new
      end

      def token
        # Possible two worker running, one worker refresh token, other unaware, so must read every time
        read_token_from_store
        refresh if remain_life_seconds < @random_generator.rand(30..(3 * 60))
        access_token
      end

      protected

      def read_token_from_store
        td = read_token
        @token_life_in_seconds = td.fetch('token_expires_in').to_i
        @got_token_at = td.fetch('got_token_at').to_i
        @access_token = td.fetch('access_token') # return access_token same time
      rescue JSON::ParserError, Errno::ENOENT, KeyError, TypeError
        refresh
      end

      def write_token_to_store(token_hash)
        raise InvalidCredentialError unless token_hash.is_a?(Hash) && token_hash['access_token']

        token_hash['got_token_at'] = Time.now.to_i
        token_hash['token_expires_in'] = token_hash.delete('expires_in')
        write_token(token_hash)
      end

      def read_token
        if record_based_token?
          throw_error_if_missing_attributes!

          {
            'access_token' => record.access_token,
            'got_token_at' => record.got_token_at,
            'token_expires_in' => record.token_expires_in
          }
        else
          JSON.parse(File.read(token_file))
        end
      end

      def write_token(token_hash)
        if record_based_token?
          write_token_to_record(token_hash)
        else
          File.write(token_file, token_hash.to_json)
        end
      end

      def remain_life_seconds
        token_life_in_seconds - (Time.now.to_i - got_token_at)
      end

      private

      def record_based_token?
        record.present?
      end

      def write_token_to_record(token_hash)
        throw_error_if_missing_attributes!

        record.access_token = token_hash['access_token']
        record.token_expires_in = token_hash['token_expires_in']
        record.got_token_at = Time.now
        record.save || record.save(validate: false)
      end

      def missing_necessary_attributes?
        return true unless record.respond_to?(:access_token)
        return true unless record.respond_to?(:token_expires_in)
        return true unless record.respond_to?(:got_token_at)

        false
      end

      def throw_error_if_missing_attributes!
        raise "Missing attributes #access_token or #token_expires_in or #got_token_at in #{record.class.name}" if missing_necessary_attributes?
      end
    end
  end
end
