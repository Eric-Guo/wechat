module Wechat
  class Message

    JSON_KEY_MAP = {
      "ToUserName" => "touser",
      "MediaId" => "media_id",
      "ThumbMediaId" => "thumb_media_id"
    }

    class << self
      def from_hash message_hash
        self.new(message_hash)
      end

      def to to_user
        self.new(:ToUserName=>to_user, :CreateTime=>Time.now.to_i)
      end
    end

    class ArticleBuilder
      attr_reader :items
      delegate :count, to: :items
      def initialize 
        @items=Array.new
      end

      def item title: "title", description: nil, pic_url: nil, url: nil
        items << {:Title=> title, :Description=> description, :PicUrl=> pic_url, :Url=> url}
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
        :ToUserName=>message_hash[:FromUserName], 
        :FromUserName=>message_hash[:ToUserName], 
        :CreateTime=>Time.now.to_i
      )
    end

    def as type
      case type
      when :text
        message_hash[:Content]

      when :image, :voice, :video
        Wechat.api.media(message_hash[:MediaId])

      when :location
        message_hash.slice(:Location_X, :Location_Y, :Scale, :Label).inject({}){|results, value| 
          results[value[0].to_s.underscore.to_sym] = value[1]; results}
      else
        raise "Don't know how to parse message as #{type}"
      end
    end

    def to openid
      update(:ToUserName=>openid)
    end

    def text content
      update(:MsgType=>"text", :Content=>content)
    end

    def image media_id
      update(:MsgType=>"image", :Image=>{:MediaId=>media_id})
    end

    def voice media_id
      update(:MsgType=>"voice", :Voice=>{:MediaId=>media_id})
    end

    def video media_id, opts={}
      video_fields = camelize_hash_keys({media_id: media_id}.merge(opts.slice(:title, :description)))
      update(:MsgType=>"video", :Video=>video_fields)
    end

    def music thumb_media_id, music_url, opts={}
      music_fields = camelize_hash_keys(opts.slice(:title, :description, :HQ_music_url).merge(music_url: music_url, thumb_media_id: thumb_media_id))
      update(:MsgType=>"music", :Music=>music_fields)
    end

    def news collection, &block
      if block_given?
        article = ArticleBuilder.new
        collection.each{|item| yield(article, item)}
        items = article.items
      else
        items = collection.collect do |item| 
         camelize_hash_keys(item.symbolize_keys.slice(:title, :description, :pic_url, :url))
        end
      end

      update(:MsgType=>"news", :ArticleCount=> items.count, 
        :Articles=> items.collect{|item| camelize_hash_keys(item)})
    end

    def to_xml
      message_hash.to_xml(root: "xml", children: "item", skip_instruct: true, skip_types: true)
    end

    def to_json
      json_hash = deep_recursive(message_hash) do |key, value|
        key = key.to_s
        [(JSON_KEY_MAP[key] || key.downcase), value]
      end

      json_hash.slice!("touser", "msgtype", "content", "image", "voice", "video", "music", "news", "articles").to_hash
      case json_hash["msgtype"]
      when "text"
        json_hash["text"] = {"content" => json_hash.delete("content")}
      when "news"
        json_hash["news"] = {"articles" => json_hash.delete("articles")}
      end
      JSON.generate(json_hash)
    end

    def save_to! model_class
      model = model_class.new(underscore_hash_keys(message_hash))
      model.save!
      return self
    end

    private
    def camelize_hash_keys hash
      deep_recursive(hash){|key, value| [key.to_s.camelize.to_sym, value]} 
    end

    def underscore_hash_keys hash
      deep_recursive(hash){|key, value| [key.to_s.underscore.to_sym, value]} 
    end

    def update fields={}
      message_hash.merge!(fields)
      return self
    end

    def deep_recursive hash, &block
      hash.inject({}) do |memo, val|
        key,value = *val
        case value.class.name
        when "Hash"
          value = deep_recursive(value, &block)
        when "Array"
          value = value.collect{|item| item.is_a?(Hash) ? deep_recursive(item, &block) : item}
        end

        key,value = yield(key, value)
        memo.merge!(key => value)
      end
    end

  end
end
