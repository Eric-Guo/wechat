# frozen_string_literal: true

require 'active_support/time_with_zone'

module Wechat
  module Qcloud
    FILE_TYPE_JSON = 1
    FILE_TYPE_CSV = 2
    CONFLICT_MODE_INSERT = 1
    CONFLICT_MODE_UPSERT = 2

    class Token
      attr_reader :client, :access_token, :qcloud_env, :qcloud_token_file, :qcloud_token_lifespan, :qcloud_token, :qcloud_token_expired_time

      def initialize(client, access_token, qcloud_setting)
        @client = client
        @access_token = access_token
        @qcloud_env = qcloud_setting.qcloud_env
        @qcloud_token_file = qcloud_setting.qcloud_token
        @qcloud_token_lifespan = qcloud_setting.qcloud_token_lifespan
        @random_generator = Random.new
      end

      def token(tries = 2)
        # Possible two worker running, one worker refresh ticket, other unaware, so must read every time
        read_qcloud_token_from_store
        refresh if remain_life_seconds < @random_generator.rand(30..(3 * 60))
        qcloud_token
      rescue AccessTokenExpiredError
        access_token.refresh
        retry unless (tries -= 1).zero?
      end

      def refresh
        data = client.post('getqcloudtoken', JSON.generate(lifespan: qcloud_token_lifespan), base: ::Wechat::ApiBase::TCB_BASE, params: { access_token: access_token.token })
        write_qcloud_token_to_store(data)
        read_qcloud_token_from_store
      end

      protected

      def read_qcloud_token_from_store
        td = read_qcloud_token
        @qcloud_token_expired_time = td.fetch('qcloud_token_expired_time').to_i
        @qcloud_token = td.fetch('token') # return qcloud_token same time
      rescue JSON::ParserError, Errno::ENOENT, KeyError, TypeError
        refresh
      end

      def write_qcloud_token_to_store(qcloud_token_hash)
        qcloud_token_hash['qcloud_token_expired_time'] = qcloud_token_hash.delete('expired_time')
        write_qcloud_token(qcloud_token_hash)
      end

      def read_qcloud_token
        JSON.parse(File.read(qcloud_token_file))
      end

      def write_qcloud_token(qcloud_token_hash)
        File.write(qcloud_token_file, qcloud_token_hash.to_json)
      end

      def remain_life_seconds
        qcloud_token_expired_time - Time.zone.now.to_i
      end
    end
  end
end
