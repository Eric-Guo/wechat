module Wechat
  module Responder
    extend ActiveSupport::Concern

    included do 
      self.skip_before_filter :verify_authenticity_token
      self.before_filter :verify_signature, only: [:show, :create]
      #delegate :wehcat, to: :class
    end

    module ClassMethods

      attr_accessor :wechat, :token

      def on message_type, with: nil, respond: nil, &block
        raise "Unknow message type" unless message_type.in? [:text, :image, :voice, :video, :location, :link, :event, :fallback]
        config=respond.nil? ? {} : {:respond=>respond}
        config.merge!(:proc=>block) if block_given?

        if (with.present? && !message_type.in?([:text, :event]))
          raise "Only text and event message can take :with parameters"
        else
          config.merge!(:with=>with) if with.present?
        end

        responders(message_type) << config
        return config
      end

      def responders type
        @responders ||= Hash.new
        @responders[type] ||= Array.new
      end

      def responder_for message, &block
        message_type = message[:MsgType].to_sym
        responders = responders(message_type)

        case message_type
        when :text
          yield(* match_responders(responders, message[:Content]))

        when :event
          yield(* match_responders(responders, message[:Event]))

        else
          yield(responders.first)
        end
      end

      private 

      def match_responders responders, value
        matched = responders.inject({scoped:nil, general:nil}) do |matched, responder|
          condition = responder[:with]

          if condition.nil?
            matched[:general] ||= [responder, value]
            next matched
          end
          
          if condition.is_a? Regexp
            matched[:scoped] ||= [responder] + $~.captures if(value =~ condition)
          else
            matched[:scoped] ||= [responder, value] if(value == condition)
          end
          matched
        end
        return matched[:scoped] || matched[:general] 
      end
    end

    
    def show
      render :text => params[:echostr]
    end

    def create
      request = Wechat::Message.from_hash(params[:xml])
      response = self.class.responder_for(request) do |responder, *args|
        responder ||= self.class.responders(:fallback).first

        next if responder.nil?
        next request.reply.text responder[:respond] if (responder[:respond])
        next responder[:proc].call(*args.unshift(request)) if (responder[:proc])
      end

      if response.respond_to? :to_xml
        render xml: response.to_xml
      else
        render :nothing => true, :status => 200, :content_type => 'text/html'
      end
    end

    private
    def verify_signature
      array = [self.class.token, params[:timestamp], params[:nonce]].compact.sort
      render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
    end
  end
end