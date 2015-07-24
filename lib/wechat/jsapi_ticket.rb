module Wechat
  class JsapiTicket
    attr_reader :client, :access_token, :jsapi_ticket_file, :jsapi_ticket_data

    def initialize(client, access_token, jsapi_ticket_file)
      @client = client
      @access_token = access_token
      @jsapi_ticket_file = jsapi_ticket_file
    end

    def ticket
      begin
        @jsapi_ticket_data ||= JSON.parse(File.read(jsapi_ticket_file))
      rescue
        self.refresh
      end
      return valid_ticket(@jsapi_ticket_data)
    end

    def refresh
      data = client.get("ticket/getticket", params: { access_token: access_token.token, type: "jsapi"})
      File.open(jsapi_ticket_file, 'w'){|f| f.write(data.to_json)} if valid_ticket(data)
      return @jsapi_ticket_data = data
    end

    private 
    def valid_ticket jsapi_ticket_data
      ticket = jsapi_ticket_data["ticket"]
      raise "Response didn't have ticket" if  ticket.blank?
      return ticket
    end

  end
end
