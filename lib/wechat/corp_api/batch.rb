module Wechat
  module CorpApi
    module Batch
      def batch_job_result(jobid)
        get 'batch/getresult', params: { jobid: jobid }
      end

      def batch_replaceparty(media_id)
        post 'batch/replaceparty', JSON.generate(media_id: media_id)
      end

      def batch_syncuser(media_id)
        post 'batch/syncuser', JSON.generate(media_id: media_id)
      end

      def batch_replaceuser(media_id)
        post 'batch/replaceuser', JSON.generate(media_id: media_id)
      end
    end
  end
end
