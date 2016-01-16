module Wechat
  class Message
    class << self
      def from_hash(message_hash)
        new(message_hash)
      end

      def to(to_user)
        new(ToUserName: to_user, CreateTime: Time.now.to_i)
      end
    end

    class ArticleBuilder
      attr_reader :items
      delegate :count, to: :items
      def initialize
        @items = []
      end

      def item(title: 'title', description: nil, pic_url: nil, url: nil)
        items << { Title: title, Description: description, PicUrl: pic_url, Url: url }.reject { |_k, v| v.nil? }
      end
    end

    attr_reader :message_hash

    def initialize(message_hash)
      @message_hash = message_hash || {}
      session
    end

    def [](key)
      message_hash[key]
    end

    def merge(other_hash)
      @message_hash.merge!(other_hash)
    end

    def reply
      Message.new(
        ToUserName: message_hash[:FromUserName],
        FromUserName: message_hash[:ToUserName],
        CreateTime: Time.now.to_i,
        session: session
      )
    end

    def session
      @message_hash[:session] ||= Wechat::WechatLog.find_session(message_hash[:FromUserName]) || {}
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
        fail "Don't know how to parse message as #{type}"
      end
    end

    def to(openid)
      update(ToUserName: openid)
    end

    def agent_id(agentid)
      update(AgentId: agentid)
    end

    def text(content)
      update(MsgType: 'text', Content: content)
    end

    def transfer_customer_service
      update(MsgType: 'transfer_customer_service')
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

    def music(thumb_media_id, music_url, opts = {})
      music_fields = camelize_hash_keys(opts.slice(:title, :description, :HQ_music_url).merge(music_url: music_url, thumb_media_id: thumb_media_id))
      update(MsgType: 'music', Music: music_fields)
    end

    def news(collection, &block)
      if block_given?
        article = ArticleBuilder.new
        collection.take(10).each_with_index { |item, index| yield(article, item, index) }
        items = article.items
      else
        items = collection.collect do |item|
          camelize_hash_keys(item.symbolize_keys.slice(:title, :description, :pic_url, :url).reject { |_k, v| v.nil? })
        end
      end

      update(MsgType: 'news', ArticleCount: items.count,
             Articles: items.collect { |item| camelize_hash_keys(item) })
    end

    def template(opts = {})
      template_fields = camelize_hash_keys(opts.symbolize_keys.slice(:template_id, :topcolor, :url, :data))
      update(MsgType: 'template', Template: template_fields)
    end

    def to_xml
      message_hash.to_xml(root: 'xml', children: 'item', skip_instruct: true, skip_types: true)
    end

    TO_JSON_KEY_MAP = {
      'ToUserName' => 'touser',
      'MediaId' => 'media_id',
      'ThumbMediaId' => 'thumb_media_id',
      'TemplateId' => 'template_id'
    }

    TO_JSON_ALLOWED = %w(touser msgtype content image voice video music news articles template agentid)

    def to_json
      json_hash = deep_recursive(message_hash) do |key, value|
        key = key.to_s
        [(TO_JSON_KEY_MAP[key] || key.downcase), value]
      end

      json_hash = json_hash.select { |k, _v| TO_JSON_ALLOWED.include? k }
      case json_hash['msgtype']
      when 'text'
        json_hash['text'] = { 'content' => json_hash.delete('content') }
      when 'news'
        json_hash['news'] = { 'articles' => json_hash.delete('articles') }
      when 'template'
        json_hash.merge! json_hash['template']
      end
      JSON.generate(json_hash)
    end

    def save_to!(model_class)
      model = model_class.new(underscore_hash_keys(message_hash.tap { |hs| hs.delete(:session) }))
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

        key, value = yield(key, value)
        memo.merge!(key => value)
      end
    end
  end
end
