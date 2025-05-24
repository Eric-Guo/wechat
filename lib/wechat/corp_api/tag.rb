module Wechat
  module CorpApi
    module Tag
      def tag_create(tagname, tagid = nil)
        post 'tag/create', JSON.generate(tagname: tagname, tagid: tagid)
      end

      def tag_update(tagid, tagname)
        post 'tag/update', JSON.generate(tagid: tagid, tagname: tagname)
      end

      def tag_delete(tagid)
        get 'tag/delete', params: { tagid: tagid }
      end

      def tags
        get 'tag/list'
      end

      def tag(tagid)
        get 'tag/get', params: { tagid: tagid }
      end

      def tag_add_user(tagid, userids = nil, departmentids = nil)
        post 'tag/addtagusers', JSON.generate(tagid: tagid, userlist: userids, partylist: departmentids)
      end

      def tag_del_user(tagid, userids = nil, departmentids = nil)
        post 'tag/deltagusers', JSON.generate(tagid: tagid, userlist: userids, partylist: departmentids)
      end
    end
  end
end
