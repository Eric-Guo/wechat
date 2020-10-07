# frozen_string_literal: true

module Wechat
  module Concern
    module Qcloud
      def invokecloudfunction(function_name, post_body_params)
        post 'invokecloudfunction', JSON.generate(post_body_params), params: { env: qcloud.qcloud_env, name: function_name }, base: Wechat::Api::TCB_BASE
      end

      def databasemigrateimport(collection_name, file_path, file_type: Wechat::Qcloud::FILE_TYPE_JSON, stop_on_error: false, conflict_mode: Wechat::Qcloud::CONFLICT_MODE_UPSERT)
        import_params_hash = { env: qcloud.qcloud_env,
                               collection_name: collection_name,
                               file_path: file_path,
                               file_type: file_type,
                               stop_on_error: stop_on_error,
                               conflict_mode: conflict_mode }
        post 'databasemigrateimport', JSON.generate(import_params_hash), base: Wechat::Api::TCB_BASE
      end

      def databasemigrateexport(query, file_path, file_type: Wechat::Qcloud::FILE_TYPE_JSON)
        export_params_hash = { env: qcloud.qcloud_env,
                               file_path: file_path,
                               file_type: file_type,
                               query: query }
        post 'databasemigrateexport', JSON.generate(export_params_hash), base: Wechat::Api::TCB_BASE
      end

      def databasemigratequeryinfo(job_id)
        query_info_hash = { env: qcloud.qcloud_env,
                            job_id: job_id }

        post 'databasemigratequeryinfo', JSON.generate(query_info_hash), base: Wechat::Api::TCB_BASE
      end

      def updateindex(collection_name, create_indexes: [], drop_indexes: [])
        update_index_params_hash = { env: qcloud.qcloud_env,
                                     collection_name: collection_name,
                                     create_indexes: create_indexes,
                                     drop_indexes: drop_indexes }
        post 'updateindex', JSON.generate(update_index_params_hash), base: Wechat::Api::TCB_BASE
      end

      def databasecollectionadd(collection_name)
        collection_add_params_hash = { env: qcloud.qcloud_env,
                                       collection_name: collection_name }
        post 'databasecollectionadd', JSON.generate(collection_add_params_hash), base: Wechat::Api::TCB_BASE
      end

      def databasecollectiondelete(collection_name)
        collection_delete_params_hash = { env: qcloud.qcloud_env,
                                          collection_name: collection_name }
        post 'databasecollectionadd', JSON.generate(collection_delete_params_hash), base: Wechat::Api::TCB_BASE
      end
    end
  end
end
