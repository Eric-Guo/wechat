module WechatHandler
  module Handler
    extend ActiveSupport::Concern

    included do 
      self.skip_before_filter :verify_authenticity_token
      self.before_filter :verify_signature, only: [:show, :create]
    end

    module ClassMethods

      def find_handler message
        message_type = message[:MsgType]
        matched = handlers.select do |handler|
          if message_type == handler[:message]
            if handler[:with].present?
              handler[:with] == handler[:with].select{|key, match| match.is_a?(Regexp) ? message[key] =~ match : message[key] == match}
            else
              true
            end
          else
            false
          end
        end
        return matched.first unless matched.empty?
        handlers.select{|handler| handler[:message]=="default"}.first
      end

      def handlers
        @handlers ||= Array.new
      end

      def on opts={}, &block 
        opts ||= {}
        handlers << opts.merge(proc: block)
      end
    end

    
    def show
      render :text => params[:echostr]
    end

    def create
      message = OpenStruct.new(params[:xml])
      message_type = message.MsgType.to_sym
      
      replier_config = self.class.find_handler(message)
      response = Wechat::Response.new(message)

      if (replier_config[:response].present?)
        response.text(replier_config[:response])
      else
        replier_config[:proc].call(response, message)
      end

      render xml: response.doc.root
    end

    private
    def verify_signature
      array = [WechatRails.config.token, params[:timestamp], params[:nonce]].compact.sort
      render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
    end
  end
end