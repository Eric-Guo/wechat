module Wechat
  module CorpApi
    module Department
      def department_create(name, parentid)
        post 'department/create', JSON.generate(name: name, parentid: parentid)
      end

      def department_delete(departmentid)
        get 'department/delete', params: { id: departmentid }
      end

      def department_update(departmentid, name = nil, parentid = nil, order = nil)
        post 'department/update', JSON.generate({ id: departmentid, name: name, parentid: parentid, order: order }.compact)
      end

      def department(departmentid = 1)
        get 'department/list', params: { id: departmentid }
      end
    end
  end
end
