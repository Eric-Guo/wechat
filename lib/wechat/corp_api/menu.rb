module Wechat
  module CorpApi
    module Menu
      def menu
        get 'menu/get', params: { agentid: agentid }
      end

      def menu_delete
        get 'menu/delete', params: { agentid: agentid }
      end

      def menu_create(menu)
        # 微信不接受 7bit escaped json(eg \uxxxx)，中文必须 UTF-8 编码，这可能是个安全漏洞
        post 'menu/create', JSON.generate(menu), params: { agentid: agentid }
      end
    end
  end
end
