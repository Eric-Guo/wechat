# frozen_string_literal: true

module Wechat
  module Concern
    module Draft
      def draft_add(mpnews_articles)
        draft_add_params_hash = { articles: mpnews_articles }
        post 'draft/add', JSON.generate(draft_add_params_hash)
      end

      def draft_get(media_id)
        post 'draft/get', JSON.generate(media_id: media_id)
      end

      def draft_delete(media_id)
        post 'draft/delete', JSON.generate(media_id: media_id)
      end

      def draft_update(media_id, mpnews_articles, index: 0)
        draft_update_params_hash = { media_id: media_id,
                                     index: index,
                                     articles: mpnews_articles }
        post 'draft/update', JSON.generate(draft_update_params_hash)
      end

      def draft_count
        get 'draft/count'
      end

      def draft_batchget(offset, count, no_content: false)
        draft_batchget_params_hash = { offset: offset,
                                       count: count,
                                       no_content: (no_content ? 1 : 0) }
        post 'draft/batchget', JSON.generate(draft_batchget_params_hash)
      end

      def draft_switch(checkonly: true)
        post 'draft/switch', nil, params: { checkonly: (checkonly ? 1 : 0) }
      end
    end
  end
end
