require 'English'

module Wechat
  module Responder
    extend ActiveSupport::Concern
    include Cipher

    included do
      skip_before_filter :verify_authenticity_token
      before_filter :verify_signature, only: [:show, :create]
      #delegate :wechat, to: :class
    end

    module ClassMethods
      attr_accessor :wechat, :token, :corpid, :agentid, :encrypt_mode, :encoding_aes_key

      def on(message_type, with: nil, respond: nil, &block)
        raise 'Unknow message type' unless message_type.in? [:text, :image, :voice, :video, :location, :link, :event, :fallback]
        config = respond.nil? ? {} : { respond: respond }
        config.merge!(proc: block) if block_given?

        if with.present? && !message_type.in?([:text, :event])
          raise 'Only text and event message can take :with parameters'
        else
          config.merge!(with: with) if with.present?
        end

        responders(message_type) << config
        config
      end

      def responders(type)
        @responders ||= {}
        @responders[type] ||= []
      end

      def responder_for(message, &block)
        message_type = message[:MsgType].to_sym
        responders = responders(message_type)

        case message_type
        when :text
          yield(* match_responders(responders, message[:Content]))

        when :event
          if message[:Event] == 'click'
            yield(* match_responders(responders, message[:EventKey]))
          else
            yield(* match_responders(responders, message[:Event]))
          end
        else
          yield(responders.first)
        end
      end

      private

      def match_responders(responders, value)
        matched = responders.each_with_object({}) do |responder, memo|
          condition = responder[:with]

          if condition.nil?
            memo[:general] ||= [responder, value]
            next
          end

          if condition.is_a? Regexp
            memo[:scoped] ||= [responder] + $LAST_MATCH_INFO.captures if value =~ condition
          else
            memo[:scoped] ||= [responder, value] if value == condition
          end
        end
        matched[:scoped] || matched[:general]
      end
    end

    def show
      if self.class.corpid.present?
        echostr, _corp_id = unpack(decrypt(Base64.decode64(params[:echostr]), self.class.encoding_aes_key))
        render text: echostr
      else
        render text: params[:echostr]
      end
    end

    def create
      request = Wechat::Message.from_hash(post_xml)
      response = self.class.responder_for(request) do |responder, *args|
        responder ||= self.class.responders(:fallback).first

        next if responder.nil?
        case
        when responder[:respond]
          request.reply.text responder[:respond]
        when responder[:proc]
          define_singleton_method :process, responder[:proc]
          send(:process, *args.unshift(request))
        else
          next
        end
      end

      if response.respond_to? :to_xml
        render xml: process_response(response)
      else
        render nothing: true, status: 200, content_type: 'text/html'
      end
    end

    private

    def verify_signature
      signature = params[:signature] || params[:msg_signature]

      render text: 'Forbidden', status: 403 if signature != Digest::SHA1.hexdigest(content_to_verify)
    end

    def content_to_verify
      array = [self.class.token, params[:timestamp], params[:nonce]]

      # 默认使用明文方式验证, 企业号验证加密签名
      if params[:signature].blank? && params[:msg_signature]
        if params[:echostr].present?
          array << params[:echostr]
        else
          array << request_content['xml']['Encrypt']
        end
      end

      array.compact.collect(&:to_s).sort.join
    end

    def post_xml
      data = request_content

      # 如果是加密模式解密
      if self.class.encrypt_mode || self.class.corpid.present?
        encrypt_msg = data['xml']['Encrypt']
        if encrypt_msg.present?
          content, @app_id = unpack(decrypt(Base64.decode64(encrypt_msg), self.class.encoding_aes_key))
          data = Hash.from_xml(content)
        end
      end

      HashWithIndifferentAccess.new_from_hash_copying_default(data.fetch('xml', {})).tap do |msg|
        msg[:Event].downcase! if msg[:Event]
      end
    end

    def process_response(response)
      msg = response.to_xml

      # 返回加密消息
      if self.class.encrypt_mode || self.class.corpid.present?
        data = request_content
        if data['xml']['Encrypt']
          encrypt = Base64.strict_encode64 encrypt(pack(msg, @app_id), self.class.encoding_aes_key)
          msg = gen_msg(encrypt, params[:timestamp], params[:nonce])
        end
      end

      msg
    end

    def gen_msg(encrypt, timestamp, nonce)
      msg_sign = Digest::SHA1.hexdigest [self.class.token, encrypt, timestamp, nonce].compact.collect(&:to_s).sort.join

      { Encrypt: encrypt,
        MsgSignature: msg_sign,
        TimeStamp: timestamp,
        Nonce: nonce
      }.to_xml(root: 'xml', children: 'item', skip_instruct: true, skip_types: true)
    end

    def request_content
      params[:xml].nil? ? Hash.from_xml(request.raw_post) : { 'xml' => params[:xml] }
    end
  end
end
