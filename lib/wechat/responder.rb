require 'English'
require 'wechat/signature'

module Wechat
  module Responder
    extend ActiveSupport::Concern
    include Cipher

    included do
      # Rails 5 remove before_filter and skip_before_filter
      if defined?(:skip_before_action)
        skip_before_action :verify_authenticity_token
        before_action :verify_signature, only: [:show, :create]
      else
        skip_before_filter :verify_authenticity_token
        before_filter :verify_signature, only: [:show, :create]
      end
    end

    module ClassMethods
      attr_accessor :wechat, :token, :corpid, :agentid, :encrypt_mode, :timeout, :skip_verify_ssl, :encoding_aes_key

      def on(message_type, with: nil, respond: nil, &block)
        fail 'Unknow message type' unless [:text, :image, :voice, :video, :link, :event, :click, :view, :scan, :batch_job, :location, :fallback].include?(message_type)
        config = respond.nil? ? {} : { respond: respond }
        config.merge!(proc: block) if block_given?

        if with.present?
          fail 'Only text, event, click, view, scan and batch_job can having :with parameters' unless [:text, :event, :click, :view, :scan, :batch_job].include?(message_type)
          config.merge!(with: with)
          self.known_scan_key_lists = with if message_type == :scan
        else
          fail 'Message type click, view, scan and batch_job must specify :with parameters' if [:click, :view, :scan, :batch_job].include?(message_type)
        end

        case message_type
        when :click
          user_defined_click_responders(with) << config
        when :view
          user_defined_view_responders(with) << config
        when :batch_job
          user_defined_batch_job_responders(with) << config
        when :location
          user_defined_location_responders << config
        else
          user_defined_responders(message_type) << config
        end
        config
      end

      def user_defined_click_responders(with)
        @click_responders ||= {}
        @click_responders[with] ||= []
      end

      def user_defined_view_responders(with)
        @view_responders ||= {}
        @view_responders[with] ||= []
      end

      def user_defined_batch_job_responders(with)
        @batch_job_responders ||= {}
        @batch_job_responders[with] ||= []
      end

      def user_defined_location_responders
        @location_responders ||= []
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
          if 'click' == message[:Event] && !user_defined_click_responders(message[:EventKey]).empty?
            yield(* user_defined_click_responders(message[:EventKey]), message[:EventKey])
          elsif 'view' == message[:Event] && !user_defined_view_responders(message[:EventKey]).empty?
            yield(* user_defined_view_responders(message[:EventKey]), message[:EventKey])
          elsif 'click' == message[:Event]
            yield(* match_responders(responders, message[:EventKey]))
          elsif known_scan_key_lists.include?(message[:EventKey])
            yield(* known_scan_with_match_responders(user_defined_responders(:scan), message))
          elsif 'batch_job_result' == message[:Event]
            yield(* user_defined_batch_job_responders(message[:BatchJob][:JobType]), message[:BatchJob])
          elsif 'location' == message[:Event]
            yield(* user_defined_location_responders, message)
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

      def known_scan_with_match_responders(responders, message)
        matched = responders.each_with_object({}) do |responder, memo|
          if %w(scan subscribe).include?(message[:Event]) && message[:EventKey] == responder[:with]
            memo[:scaned] ||= [responder, message[:Ticket]]
          elsif %w(scancode_push scancode_waitmsg).include?(message[:Event]) && message[:EventKey] == responder[:with]
            memo[:scaned] ||= [responder, message[:ScanCodeInfo][:ScanResult], message[:ScanCodeInfo][:ScanType]]
          end
        end
        matched[:scaned]
      end

      def known_scan_key_lists
        @known_scan_key_lists ||= []
      end

      def known_scan_key_lists=(qrscene_value)
        @known_scan_key_lists ||= []
        @known_scan_key_lists << qrscene_value
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
      if self.class.encrypt_mode
        signature = params[:signature] || params[:msg_signature]
        msg_encrypt = params[:echostr] || request_encrypt_content
      else
        signature = params[:signature]
      end

      msg_encrypt = nil unless self.class.corpid.present?

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
      if response[:MsgType] == 'success'
        msg = 'success'
      else
        msg = response.to_xml
      end

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
