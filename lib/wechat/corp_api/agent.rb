module Wechat
  module CorpApi
    module Agent
      def agent_list
        get 'agent/list'
      end

      def agent(agentid)
        get 'agent/get', params: { agentid: agentid }
      end
    end
  end
end
