require 'English'
require 'wechat/signature'

module Wechat
  module Responder
    extend ActiveSupport::Concern
    include Cipher

    included do
      skip_before_filter :verify_authenticity_token
      before_filter :verify_signature, only: [:show, :create]
    end

    module ClassMethods
      attr_accessor :wechat, :token, :corpid, :agentid, :encrypt_mode, :skip_verify_ssl, :encoding_aes_key

      def known_qrscene_lists
        @known_qrscene_lists ||= []
      end

      def known_qrscene_lists=(qrscene_value)
        @known_qrscene_lists ||= []
        @known_qrscene_lists << qrscene_value
      end

      def on(message_type, with: nil, respond: nil, &block)
        fail 'Unknow message type' unless [:text, :image, :voice, :video, :location, :link, :event, :fallback].include?(message_type)
        config = respond.nil? ? {} : { respond: respond }
        config.merge!(proc: block) if block_given?

        if with.present?
          fail 'Only text and event message can take :with parameters' unless [:text, :event].include?(message_type)
          config.merge!(with: with)
          self.known_qrscene_lists = with if with.respond_to?(:start_with?) && with.start_with?('qrscene_')
        end

        user_defined_responders(message_type) << config
        config
      end

      def user_defined_responders(type)
        @responders ||= {}
        @responders[type] ||= []
      end

      def responder_for(message)
        message_type = message[:MsgType].to_sym
        responders = user_defined_responders(message_type)

        case message_type
        when :text
          yield(* match_responders(responders, message[:Content]))
        when :event
          if 'click' == message[:Event]
            yield(* match_responders(responders, message[:EventKey]))
          elsif 'scan' == message[:Event] || ('subscribe' == message[:Event] && known_qrscene_lists.include?(message[:EventKey]))
            yield(* match_responders(responders, event: 'scancode_public',
                                                 event_key: message[:EventKey],
                                                 ticket: message[:Ticket]))
          elsif %w(scancode_push scancode_waitmsg).include? message[:Event]
            yield(* match_responders(responders, event: 'scancode_enterprise',
                                                 event_key: message[:EventKey],
                                                 scan_type: message[:ScanCodeInfo][:ScanType],
                                                 scan_result: message[:ScanCodeInfo][:ScanResult]))
          elsif 'batch_job_result' == message[:Event]
            yield(* match_responders(responders, event: 'batch_job',
                                                 batch_job: message[:BatchJob]))
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
          elsif value.is_a? Hash
            memo[:scoped] ||= [responder, value[:ticket]] if value[:event_key] == condition && value[:event] == 'scancode_public'
            memo[:scoped] ||= [responder, value[:scan_result], value[:scan_type]] if value[:event_key] == condition && value[:event] == 'scancode_enterprise'
            memo[:scoped] ||= [responder, value[:batch_job]] if value[:event] == 'batch_job' &&
                                                                %w(sync_user replace_user invite_user replace_party).include?(condition.downcase)
          else
            memo[:scoped] ||= [responder, value] if value == condition
          end
        end
        matched[:scoped] || matched[:general]
      end
    end

    def wechat
      self.class.wechat # Make sure user can continue access wechat at instance level similar to class level
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
      response = run_responder(request)

      if response.respond_to? :to_xml
        render xml: process_response(response)
      else
        render nothing: true, status: 200, content_type: 'text/html'
      end
    end

    private

    def verify_signature
      signature = params[:signature] || params[:msg_signature]

      msg_encrypt = params[:echostr] if self.class.corpid.present?
      msg_encrypt ||= request_encrypt_content if self.class.encrypt_mode

      render text: 'Forbidden', status: 403 if signature != Signature.hexdigest(self.class.token,
                                                                                params[:timestamp],
                                                                                params[:nonce],
                                                                                msg_encrypt)
    end

    def post_xml
      data = request_content

      if self.class.encrypt_mode && request_encrypt_content.present?
        content, @app_id = unpack(decrypt(Base64.decode64(request_encrypt_content), self.class.encoding_aes_key))
        data = Hash.from_xml(content)
      end

      HashWithIndifferentAccess.new_from_hash_copying_default(data.fetch('xml', {})).tap do |msg|
        msg[:Event].downcase! if msg[:Event]
      end
    end

    def run_responder(request)
      self.class.responder_for(request) do |responder, *args|
        responder ||= self.class.user_defined_responders(:fallback).first

        next if responder.nil?
        case
        when responder[:respond]
          request.reply.text responder[:respond]
        when responder[:proc]
          define_singleton_method :process, responder[:proc]
          number_of_block_parameter = responder[:proc].arity
          send(:process, *args.unshift(request).take(number_of_block_parameter))
        else
          next
        end
      end
    end

    def process_response(response)
      msg = response.to_xml

      if self.class.encrypt_mode
        encrypt = Base64.strict_encode64(encrypt(pack(msg, @app_id), self.class.encoding_aes_key))
        msg = gen_msg(encrypt, params[:timestamp], params[:nonce])
      end

      msg
    end

    def gen_msg(encrypt, timestamp, nonce)
      msg_sign = Signature.hexdigest(self.class.token, timestamp, nonce, encrypt)

      { Encrypt: encrypt,
        MsgSignature: msg_sign,
        TimeStamp: timestamp,
        Nonce: nonce
      }.to_xml(root: 'xml', children: 'item', skip_instruct: true, skip_types: true)
    end

    def request_encrypt_content
      request_content['xml']['Encrypt']
    end

    def request_content
      params[:xml].nil? ? Hash.from_xml(request.raw_post) : { 'xml' => params[:xml] }
    end
  end
end
