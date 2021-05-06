# frozen_string_literal: true

require 'wechat/token/access_token_base'

module Wechat
  module Token
    class ComponentAccessToken < AccessTokenBase
      
      def component_verify_ticket
        ticket ||= Ticket::ComponentVerifyTicket.new(ticket_file)
        ticket&.ticket
      end

      def refresh
        #  Todo: 获取component_verify_ticket
        if component_verify_ticket.blank?
          puts 'warning: component_verify_ticket is invalid! skip refresh action...'
          return nil;
        end
        data = client.get('api_component_token', params: { component_appid: appid, component_appsecret: secret, component_verify_ticket: component_verify_ticket })
        write_token_to_store(data)
        read_token_from_store
      end
    end
  end
end
