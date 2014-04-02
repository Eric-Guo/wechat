Wechat Rails
======================

[![Build Status](https://travis-ci.org/skinnyworm/omniauth-wechat-oauth2.svg)](https://travis-ci.org/skinnyworm/wechat-rails) [![Code Climate](https://codeclimate.com/github/skinnyworm/wechat-rails.png)](https://codeclimate.com/github/skinnyworm/wechat-rails) [![Code Coverage](https://codeclimate.com/github/skinnyworm/wechat-rails/coverage.png)](https://codeclimate.com/github/skinnyworm/wechat-rails) [![Gem Version](https://badge.fury.io/rb/wechat-rails.png)](http://badge.fury.io/rb/wechat-rails)


Wechat-rails 可以帮助开发者方便地在Rails环境中集成微信公众平台提供的所有服务，目前微信公众平台提供了以下几种类型的服务。

- ##### 微信公众平台基本API, 无需Web环境。
- ##### 消息处理机制, 需运行在Web环境中。
- ##### OAuth 2.0认证机制

Wechat-rails gem 包含了一个命令行程序可以调用各种无需web环境的API。同时它也提供了Rails Controller的responder DSL, 可以帮助开发者方便地在Rails应用中集成微信的消息处理机制。如果你的App还需要集成微信OAuth2.0, 你可以考虑[omniauth-wechat-oauth2](https://github.com/skinnyworm/omniauth-wechat-oauth2), 这个gem可以方便地和devise集成提供完整的用户认证.

在使用这个Gem前，你需要获得微信API的appid, secret, token。具体情况可以参见http://mp.weixin.qq.com

## 安装

Using `gem install` or add to your app's `Gemfile`:

```
gem install "wechat-rails"
```

```
gem "wechat-rails", git:"https://github.com/skinnyworm/wechat-rails"
```


## 配置

#### 命令行程序的配置

要使用命令行程序，你需要在你的home目录中创建一个`~/.wechat.yml`，包含以下内容。其中`access_token`是存放access_token的文件位置。

```
appid: "my_appid"
secret: "my_secret"
access_token: "/var/tmp/wechat_access_token"
```

#### Rails 全局配置
Rails环境中, 你可以在config中创建wechat.yml, 为每个rails environment创建不同的配置。

```
default: &default
  appid: "app_id"
  secret: "app_secret"
  token:  "app_token"
  access_token: "/var/tmp/wechat_access_token"

production: 
  appid: <%= ENV['WECHAT_APPID'] %>
  secret: <%= ENV['WECHAT_APP_SECRET'] %>
  token:   <%= ENV['WECHAT_TOKEN'] %>
  access_token:  <%= ENV['WECHAT_ACCESS_TOKEN'] %>

staging: 
  <<: *default

development: 
  <<: *default

test: 
  <<: *default
```

#### Rails 为每个Responder配置不同的appid和secret
在个别情况下，你的app可能需要处理来自多个公众账号的消息，这时你可以配置多个responder controller。

```ruby
class WechatFirstController < ApplicationController
   wechat_responder appid: "app1", secret: "secret1", token: "token1", access_token: Rails.root.join("tmp/access_token1")
   
   on :text, with:"help", respond: "help content"
end
```
    
## 使用命令行

```
$ wechat
Wechat commands:
  wechat custom_image [OPENID, IMAGE_PATH]                 # 发送图片客服消息
  wechat custom_music [OPENID, THUMBNAIL_PATH, MUSIC_URL]  # 发送音乐客服消息
  wechat custom_news [OPENID, NEWS_YAML_FILE]              # 发送图文客服消息
  wechat custom_text [OPENID, TEXT_MESSAGE]                # 发送文字客服消息
  wechat custom_video [OPENID, VIDEO_PATH]                 # 发送视频客服消息
  wechat custom_voice [OPENID, VOICE_PATH]                 # 发送语音客服消息
  wechat help [COMMAND]                                    # Describe available commands or one specific command
  wechat media [MEDIA_ID, PATH]                            # 媒体下载
  wechat media_create [MEDIA_ID, PATH]                     # 媒体上传
  wechat menu                                              # 当前菜单
  wechat menu_create [MENU_YAML]                           # 创建菜单
  wechat menu_delete                                       # 删除菜单
  wechat user [OPEN_ID]                                    # 查找关注者
  wechat users                                             # 关注者列表

```

### 使用场景
以下是几种典型场景的使用方法

#####获取所有用户的OPENID

```
$ wechat users

{"total"=>4, "count"=>4, "data"=>{"openid"=>["oCfEht9***********", "oCfEhtwqa***********", "oCfEht9oMCqGo***********", "oCfEht_81H5o2***********"]}, "next_openid"=>"oCfEht_81H5o2***********"}

```

#####获取用户的信息

```
$ wechat user "oCfEht9***********"

{"subscribe"=>1, "openid"=>"oCfEht9***********", "nickname"=>"Nickname", "sex"=>1, "language"=>"zh_CN", "city"=>"徐汇", "province"=>"上海", "country"=>"中国", "headimgurl"=>"http://wx.qlogo.cn/mmopen/ajNVdqHZLLBd0SG8NjV3UpXZuiaGGPDcaKHebTKiaTyof*********/0", "subscribe_time"=>1395715239}

```

#####获取用户的信息

```
$ wechat user "oCfEht9***********"

{"subscribe"=>1, "openid"=>"oCfEht9***********", "nickname"=>"Nickname", "sex"=>1, "language"=>"zh_CN", "city"=>"徐汇", "province"=>"上海", "country"=>"中国", "headimgurl"=>"http://wx.qlogo.cn/mmopen/ajNVdqHZLLBd0SG8NjV3UpXZuiaGGPDcaKHebTKiaTyof*********/0", "subscribe_time"=>1395715239}
```

##### 获取当前菜单
```
$ wechat menu

{"menu"=>{"button"=>[{"type"=>"view", "name"=>"保护的", "url"=>"http://***/protected", "sub_button"=>[]}, {"type"=>"view", "name"=>"公开的", "url"=>"http://***", "sub_button"=>[]}]}}

```

##### 创建菜单
创建菜单需要一个定义菜单内容的yaml文件，比如
menu.yaml

```
button:
  -
    type: "view"
    name: "保护的"
    url: "http://***/protected"
  -
    type: "view"
    name: "公开的"
    url: "http://***"
    
```

然后执行命令行

```
$ wechat menu_create menu.yaml

```

##### 发送客服图文消息
需定义一个图文消息内容的yaml文件，比如
articles.yaml

```
articles:
 -
  title: "习近平在布鲁日欧洲学院演讲"
  description: "新华网比利时布鲁日4月1日电 国家主席习近平1日在比利时布鲁日欧洲学院发表重要演讲"
  url: "http://news.sina.com.cn/c/2014-04-01/232629843387.shtml"
  pic_url: "http://i3.sinaimg.cn/dy/c/2014-04-01/1396366518_bYays1.jpg"
```

然后执行命令行

```
$ wechat custom_news oCfEht9oM*********** articles.yml 

```



## Rails Responder Controller DSL

为了在Rails app中响应用户的消息，开发者需要创建一个wechat responder controller. 首先在router中定义

```ruby
  resource :wechat, only:[:show, :create]

```

然后创建Controller class, 例如

```ruby

class WechatsController < ApplicationController
  wechat_responder
  
  # 默认的文字信息responder
  on :text do |request, content|
    request.reply.text "echo: #{content}" #Just echo
  end

  # 当请求的文字信息内容为'help'时, 使用这个responder处理
  on :text, with:"help" do |request, help|
    request.reply.text "help content" #回复帮助信息
  end

  # 当请求的文字信息内容为'<n>条新闻'时, 使用这个responder处理, 并将n作为第二个参数
  on :text, with: /^(\d+)条新闻$/ do |request, count|
    articles_range = (0... [count.to_i, 10].min)
    request.reply.news(articles_range) do |article, i| #回复"articles"
      article.item title: "标题#{i}", description:"内容描述#{i}", pic_url: "http://www.baidu.com/img/bdlogo.gif", url:"http://www.baidu.com/"
    end
  end

  # 处理图片信息
  on :image do |request|
    request.reply.image(request[:MediaId]) #直接将图片返回给用户
  end

  # 处理语音信息
  on :voice do |request|
    request.reply.voice(request[:MediaId]) #直接语音音返回给用户
  end

  # 处理视频信息
  on :video do |request|
    nickname = wechat.user(request[:FromUserName])["nickname"] #调用 api 获得发送者的nickname
    request.reply.video(request[:MediaId], title: "回声", description: "#{nickname}发来的视频请求") #直接视频返回给用户
  end

  # 处理地理位置信息
  on :location do |request|
    request.reply.text("#{request[:Location_X]}, #{request[:Location_Y]}") #回复地理位置
  end

  # 当无任何responder处理用户信息时,使用这个responder处理
  on :fallback, respond: "fallback message"  
end

```

在controller中使用`wechat_responder`引入Responder DSL, 之后可以用

```
on <message_type> do |message|
 message.reply.text "some text"
end

```
来响应用户信息。

目前支持的message_type有如下几种

- :text 响应文字消息,可以用`:with`参数来匹配文本内容 `on(:text, with:'help'){|message, content| ...}`
- :image 响应图片消息
- :voice 响应语音消息
- :video 响应视频消息
- :location 响应地理位置消息
- :link 响应链接消息
- :event 响应事件消息, 可以用`:with`参数来匹配事件类型
- :fallback 默认响应，当收到的消息无法被其他responder响应时，会使用这个responder.

## Message DSL

Wechat-rails 的核心是一个Message DSL,帮助开发者构建各种类型的消息，包括主动推送的和被动响应的。
....

  


