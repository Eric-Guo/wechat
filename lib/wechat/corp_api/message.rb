module Wechat
  module CorpApi
    module Message
      def message_send(userid, message)
        post 'message/send', Wechat::Message.to(userid).text(message).agent_id(agentid).to_json, content_type: :json
      end

      def news_message_send(userid, title, description, link_url, pic_url)
        post 'message/send', Wechat::Message.to(userid).news([{ title: title,
                                                        description: description,
                                                        url: link_url,
                                                        pic_url: pic_url }])
                                    .agent_id(agentid).to_json, content_type: :json
      end

      def custom_message_send(message)
        post 'message/send', message.is_a?(Wechat::Message) ? message.agent_id(agentid).to_json : JSON.generate(message.merge(agent_id: agentid)), content_type: :json
      end
    end
  end
end
