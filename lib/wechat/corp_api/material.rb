module Wechat
  module CorpApi
    module Material
      def material_count
        get 'material/get_count', params: { agentid: agentid }
      end

      def material_list(type, offset, count)
        post 'material/batchget', JSON.generate(type: type, agentid: agentid, offset: offset, count: count)
      end

      def get_material(media_id)
        post 'material/get_material', JSON.generate(media_id: media_id), params: { agentid: agentid }, as: :file
      end

      def material_add(type, file)
        post_file 'material/add_material', file, params: { type: type, agentid: agentid }
      end

      def material_delete(media_id)
        get 'material/del', params: { media_id: media_id, agentid: agentid }
      end
    end
  end
end
