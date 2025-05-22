# frozen_string_literal: true

module Wechat
  class Api < ApiBase
    def initialize(api_config, record = nil)
      super()
      @client = HttpClient.new(Wechat::Api::API_BASE, api_config.network_setting)
      @access_token = Token::PublicAccessToken.new(@client, api_config.appid, api_config.secret, api_config.token_file, record)
      @jsapi_ticket = Ticket::PublicJsapiTicket.new(@client, @access_token, api_config.jsapi_ticket_file)
      @qcloud = nil
    end

    include Concern::Common
    include Concern::Draft

    def template_message_send(message)
      post 'message/template/send', message.to_json, content_type: :json
    end

    def list_message_template
      get 'template/get_all_private_template'
    end

    def add_message_template(template_id_short)
      post 'template/api_add_template', JSON.generate(template_id_short: template_id_short)
    end

    def del_message_template(template_id)
      post 'template/del_private_template', JSON.generate(template_id: template_id)
    end
  end
end
