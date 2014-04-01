Wechat Rails
======================

[![Build Status](https://travis-ci.org/skinnyworm/omniauth-wechat-oauth2.svg)](https://travis-ci.org/skinnyworm/wechat-rails) [![Code Climate](https://codeclimate.com/github/skinnyworm/wechat-rails.png)](https://codeclimate.com/github/skinnyworm/wechat-rails) [![Code Coverage](https://codeclimate.com/github/skinnyworm/wechat-rails/coverage.png)](https://codeclimate.com/github/skinnyworm/wechat-rails) [![Gem Version](https://badge.fury.io/rb/wechat-rails.png)](http://badge.fury.io/rb/wechat-rails)


Wechat MP platform provides following services for developers to use

- API service (user query, media retrieval and sending custom messages)
- Messaging service (repspond to messages sent by user)
- OAuth 2.0

Wechat-rails gem helps developer to easily use the API service and Messaging service in rails app. For oauth2 integeration, you can consider [omniauth-wechat-oauth2](https://github.com/skinnyworm/omniauth-wechat-oauth2).

You need to get a wechat API key at: http://mp.weixin.qq.com

## Installation

Add to your `Gemfile`:

```ruby
gem "wechat-rails"
```

Then `bundle install`.

### Setup Environment
For development environment, you need to export some environment variables before you can use the commandline utilities.

```
export WECHAT_APPID=<app id>
export WECHAT_SECRET=<app secret>
export WECHAT_ACCESS_TOKEN=<储存access_token文件的位置, eg. /var/tmp/access_token>
export TOKEN=<Token可由开发者任意填写,用作生成签名,在配置接口时使用>
```
For production environment, consult your service configuration for how to expose your environment variables.

## Command line utilities
Once the gem was installed, you should have a command line utility for invoking all the api methods.

## Controller DSL
To set up a rails controlelr for reponding user message is easy. Following is an example

```ruby

class WechatsController < ApplicationController
  wechat_rails
  
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
    nickname = Wechat.api.user(request[:FromUserName])["nickname"] #呼叫 api 获得发送者的nickname
    request.reply.video(request[:MediaId], title: "回声", description: "#{nickname}发来的视频请求") #直接视频返回给用户
  end

  # 处理地理位置信息
  on :location do |request|
    request.reply.text("#{request[:Location_X]}, #{request[:Location_Y]}") #回复地理位置
  end

  # 当无任何responder处理用户信息时,使用这个responder处理
  on :fallback do |request|
    request.reply.text "fallback"
  end
  
end

```



