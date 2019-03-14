module Wechat
  class Message
    class << self
      def from_hash(message_hash)
        new(message_hash)
      end

      def to(to_users = '', towxname: nil, send_ignore_reprint: 0)
        if towxname.present?
          new(ToWxName: towxname, CreateTime: Time.now.to_i)
        elsif send_ignore_reprint == 1
          new(ToUserName: to_users, CreateTime: Time.now.to_i, send_ignore_reprint: send_ignore_reprint)
        else
          new(ToUserName: to_users, CreateTime: Time.now.to_i)
        end
      end

      def to_party(party)
        new(ToPartyName: party, CreateTime: Time.now.to_i)
      end

      def to_mass(tag_id: nil, send_ignore_reprint: 0)
        if tag_id
          new(filter: { is_to_all: false, tag_id: tag_id }, send_ignore_reprint: send_ignore_reprint)
        else
          new(filter: { is_to_all: true }, send_ignore_reprint: send_ignore_reprint)
        end
      end
    end

    class ArticleBuilder
      attr_reader :items
      delegate :count, to: :items
      def initialize
        @items = []
      end
    end

    class NewsArticleBuilder < ArticleBuilder
      def item(title: 'title', description: nil, pic_url: nil, url: nil)
        items << { Title: title, Description: description, PicUrl: pic_url, Url: url }.reject { |_k, v| v.nil? }
      end
    end

    class MpNewsArticleBuilder < ArticleBuilder
      def item(thumb_media_id:, title:, content:, author: nil, content_source_url: nil, digest: nil, show_cover_pic: '0')
        items << { Thumb_Media_ID: thumb_media_id, Author: author, Title: title, ContentSourceUrl: content_source_url,
                   Content: content, Digest: digest, ShowCoverPic: show_cover_pic }.reject { |_k, v| v.nil? }
      end
    end

    attr_reader :message_hash

    def initialize(message_hash)
      @message_hash = message_hash || {}
    end

    def [](key)
      message_hash[key]
    end

    def reply
      Message.new(
        ToUserName: message_hash[:FromUserName],
        FromUserName: message_hash[:ToUserName],
        CreateTime: Time.now.to_i,
        WechatSession: session
      )
    end

    def session
      return nil unless Wechat.config.have_session_class
      @message_hash[:WechatSession] ||= WechatSession.find_or_initialize_session(underscore_hash_keys(message_hash))
    end

    def save_session
      ws = message_hash.delete(:WechatSession)
      ws.try(:save_session, underscore_hash_keys(message_hash))
      @message_hash[:WechatSession] = ws
    end

    def as(type)
      case type
      when :text
        message_hash[:Content]

      when :image, :voice, :video
        Wechat.api.media(message_hash[:MediaId])

      when :location
        message_hash.slice(:Location_X, :Location_Y, :Scale, :Label).each_with_object({}) do |value, results|
          results[value[0].to_s.underscore.to_sym] = value[1]
        end
      else
        raise "Don't know how to parse message as #{type}"
      end
    end

    def to(openid_or_userid)
      update(ToUserName: openid_or_userid)
    end

    def agent_id(agentid)
      update(AgentId: agentid)
    end

    def text(content)
      update(MsgType: 'text', Content: content)
    end

    def textcard(title, description, url, btntxt = nil)
      data = {
        title: title,
        description: description,
        url: url
      }
      data[:btntxt] = btntxt if btntxt.present?
      update(MsgType: 'textcard', TextCard: data)
    end

    def markdown(content)
      update(MsgType: 'markdown', Markdown: {
        content: content
      })
    end

    def transfer_customer_service(kf_account = nil)
      if kf_account
        update(MsgType: 'transfer_customer_service', TransInfo: { KfAccount: kf_account })
      else
        update(MsgType: 'transfer_customer_service')
      end
    end

    def success
      update(MsgType: 'success')
    end

    def image(media_id)
      update(MsgType: 'image', Image: { MediaId: media_id })
    end

    def voice(media_id)
      update(MsgType: 'voice', Voice: { MediaId: media_id })
    end

    def video(media_id, opts = {})
      video_fields = camelize_hash_keys({ media_id: media_id }.merge(opts.slice(:title, :description)))
      update(MsgType: 'video', Video: video_fields)
    end

    def file(media_id)
      update(MsgType: 'file', File: { MediaId: media_id })
    end

    def music(thumb_media_id, music_url, opts = {})
      music_fields = camelize_hash_keys(opts.slice(:title, :description, :HQ_music_url).merge(music_url: music_url, thumb_media_id: thumb_media_id))
      update(MsgType: 'music', Music: music_fields)
    end

    def news(collection, &_block)
      if block_given?
        article = NewsArticleBuilder.new
        collection.take(8).each_with_index { |item, index| yield(article, item, index) }
        items = article.items
      else
        items = collection.collect do |item|
          camelize_hash_keys(item.symbolize_keys.slice(:title, :description, :pic_url, :url).reject { |_k, v| v.nil? })
        end
      end

      update(MsgType: 'news', ArticleCount: items.count,
             Articles: items.collect { |item| camelize_hash_keys(item) })
    end

    def mpnews(collection, &_block)
      if block_given?
        article = MpNewsArticleBuilder.new
        collection.take(8).each_with_index { |item, index| yield(article, item, index) }
        items = article.items
      else
        items = collection.collect do |item|
          camelize_hash_keys(item.symbolize_keys.slice(:thumb_media_id, :title, :content, :author, :content_source_url, :digest, :show_cover_pic).reject { |_k, v| v.nil? })
        end
      end

      update(MsgType: 'mpnews', Articles: items.collect { |item| camelize_hash_keys(item) })
    end

    def ref_mpnews(media_id)
      update(MsgType: 'ref_mpnews', MpNews: { MediaId: media_id })
    end

    TEMPLATE_KEYS = %i[template_id form_id page color
                       emphasis_keyword topcolor url miniprogram data].freeze

    def template(opts = {})
      template_fields = opts.symbolize_keys.slice(*TEMPLATE_KEYS)
      update(MsgType: 'template', Template: template_fields)
    end

    def to_xml
      ws = message_hash.delete(:WechatSession)
      xml = message_hash.to_xml(root: 'xml', children: 'item', skip_instruct: true, skip_types: true)
      @message_hash[:WechatSession] = ws
      xml
    end

    TO_JSON_KEY_MAP = {
      'TextCard'         => 'textcard',
      'Markdown'         => 'markdown',
      'ToUserName'       => 'touser',
      'ToPartyName'     => 'toparty',
      'ToWxName'         => 'towxname',
      'MediaId'          => 'media_id',
      'MpNews'           => 'mpnews',
      'ThumbMediaId'     => 'thumb_media_id',
      'TemplateId'       => 'template_id',
      'FormId'           => 'form_id',
      'ContentSourceUrl' => 'content_source_url',
      'ShowCoverPic'     => 'show_cover_pic'
    }.freeze

    TO_JSON_ALLOWED = %w[touser toparty msgtype content image voice video file textcard markdown
                         music news articles template agentid filter
                         send_ignore_reprint mpnews towxname].freeze

    def to_json
      keep_camel_case_key = message_hash[:MsgType] == 'template'
      json_hash = deep_recursive(message_hash) do |key, value|
        key = key.to_s
        [(TO_JSON_KEY_MAP[key] || (keep_camel_case_key ? key : key.downcase)), value]
      end
      json_hash = json_hash.transform_keys(&:downcase).select { |k, _v| TO_JSON_ALLOWED.include? k }

      case json_hash['msgtype']
      when 'text'
        json_hash['text'] = { 'content' => json_hash.delete('content') }
      when 'news'
        json_hash['news'] = { 'articles' => json_hash.delete('articles') }
      when 'mpnews'
        json_hash = { 'articles' => json_hash['articles'] }
      when 'ref_mpnews'
        json_hash['msgtype'] = 'mpnews'
        json_hash.delete('articles')
      when 'template'
        json_hash = { 'touser' => json_hash['touser'] }.merge!(json_hash['template'])
      end
      JSON.generate(json_hash)
    end

    def save_to!(model_class)
      model = model_class.new(underscore_hash_keys(message_hash))
      model.save!
      self
    end

    private

    def camelize_hash_keys(hash)
      deep_recursive(hash) { |key, value| [key.to_s.camelize.to_sym, value] }
    end

    def underscore_hash_keys(hash)
      deep_recursive(hash) { |key, value| [key.to_s.underscore.to_sym, value] }
    end

    def update(fields = {})
      message_hash.merge!(fields)
      self
    end

    def deep_recursive(hash, &block)
      hash.inject({}) do |memo, val|
        key, value = *val
        case value.class.name
        when 'Hash'
          value = deep_recursive(value, &block)
        when 'Array'
          value = value.collect { |item| item.is_a?(Hash) ? deep_recursive(item, &block) : item }
        end

        key, value = yield(key, value) unless key == :WechatSession
        memo.merge!(key => value)
      end
    end
  end
end
