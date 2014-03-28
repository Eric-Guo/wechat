module WechatHandler
  class Response
    attr_reader :message, :doc

    class ArticalBuilder
      attr_reader :items
      delegate :count, to: :items
      def initialize 
        @items=Array.new
      end

      def item title: "title", description: nil, pic_url: nil, url: nil
        items << {title: title, description: description, pic_url: pic_url, url: url}
      end
    end

    def initialize message
      @message = message
    end

    def text content
      @doc = reply_xml("text") do |xml|
        fields(xml, content: content)
      end
    end

    def image media_id
      @doc = reply_xml("image")do |xml|
        xml.Image{fields(xml, media_id: media_id)}
      end
    end

    def voice media_id
      @doc = reply_xml("voice")do |xml|
        xml.Voice{fields(xml, media_id: media_id)}
      end
    end

    def video media_id, opts={}
      opts = opts.slice(:title, :description).merge(media_id: media_id)
      @doc = reply_xml("video")do |xml|
        xml.Video{ fields(xml, opts)}
      end
    end

    def music thumb_media_id, music_url, opts={}
      opts = opts.slice(:title, :description, :HQ_music_url).merge(music_url: music_url, thumb_media_id: thumb_media_id)
      @doc = reply_xml("music")do |xml|
        xml.Music{fields(xml, opts)}
      end
    end

    def news collection, &block
      raise "no block given to convert item to artical" unless block_given?
      artical = ArticalBuilder.new
      collection.each{|item| yield(artical, item)}

      @doc = reply_xml("news") do |xml|
        xml.ArticleCount(artical.count)
        xml.Articles {
          artical.items.each do |item|
            xml.item{
              fields(xml, item.slice(:title, :description, :pic_url, :url))
            }
          end
        }
      end

    end

    private
    def reply_xml type, fields={}, &block
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.xml {
          xml.ToUserName{xml.cdata(message.FromUserName)}
          xml.FromUserName{xml.cdata(message.ToUserName)}
          xml.MsgType{xml.cdata(type)}
          xml.CreateTime Time.now.to_i

          yield(xml) if block_given?
        }
      end
      builder.doc
    end

    def fields xml, fields
      fields.each do |name, value|
        xml.send(name.to_s.camelcase.to_sym){xml.cdata(value)} unless value.nil?
      end
    end

  end
end