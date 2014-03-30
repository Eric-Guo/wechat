module WechatRails
  class Message
    

    class << self
      def from_hash message_hash
        self.new(message_hash)
      end

      def to to_user
        self.new(:ToUserName=>to_user, :CreateTime=>Time.now.to_i)
      end
    end

    class ArticalBuilder
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
      video_fields = camelize_hash_keys(opts.slice(:title, :description).merge(media_id: media_id))
      update(:MsgType=>"video", :Video=>video_fields)
    end

    def music thumb_media_id, music_url, opts={}
      music_fields = camelize_hash_keys(opts.slice(:title, :description, :HQ_music_url).merge(music_url: music_url, thumb_media_id: thumb_media_id))
      update(:MsgType=>"music", :Music=>music_fields)
    end

    def news collection, &block
      if block_given?
        artical = ArticalBuilder.new
        collection.each{|item| yield(artical, item)}
        items = artical.items
      else
        items = collection.collect do |item| 
         camelize_hash_keys(item.slice(:title, :description, :pic_url, :url))
        end
      end

      update(:MsgType=>"news", :ArticleCount=> items.count, 
        :Articles=> items.collect{|item| {:item => camelize_hash_keys(item)} })
    end

    private
    def camelize_hash_keys hash
      hash.inject({}) do |memo, val|
        memo[val.first.to_s.camelize.to_sym] = val.second
        memo
      end
    end

    def update fields={}
      message_hash.merge!(fields)
      return self
    end

  end
end
