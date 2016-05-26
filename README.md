WeChat [![Gem Version][version-badge]][rubygems] [![Build Status][travis-badge]][travis] [![Code Climate][codeclimate-badge]][codeclimate] [![Code Coverage][codecoverage-badge]][codecoverage]
======

[![Join the chat][gitter-badge]][gitter] [![Issue Stats][issue-badge]][issuestats] [![PR Stats][pr-badge]][issuestats]

[中文文档 Chinese document](/README-CN.md)

[Wechat](http://www.wechat.com/) is a free messaging and calling app developed by [Tencent](http://tencent.com/en-us/index.shtml), after linked billion people, Wechat become a platform of application

WeChat gem trying to helping Rails developer to integrated [enterprise account](https://qy.weixin.qq.com) / [public account](https://mp.weixin.qq.com/) easily. Below feature is ready and no need writing adapter code talking to wechat server directly.

- [Sending message](http://qydev.weixin.qq.com/wiki/index.php?title=%E5%8F%91%E9%80%81%E6%B6%88%E6%81%AF) API（Can access via console or in rails）
- [Receiving message](http://qydev.weixin.qq.com/wiki/index.php?title=%E6%8E%A5%E6%94%B6%E6%B6%88%E6%81%AF%E4%B8%8E%E4%BA%8B%E4%BB%B6)（You must running on rails server to receiving message）
- [Wechat JS-SDK](http://qydev.weixin.qq.com/wiki/index.php?title=%E5%BE%AE%E4%BF%A1JS%E6%8E%A5%E5%8F%A3) config signature
- OAuth 2.0 authentication
- Record session when received message from user (Optional)


`wechat` command share the same API in console, so you can interactive with wechat server quickly, without starting up web environment/code.

A responder DSL can used in Rails controller, so giving a event based interface to handler message sent by end user from wechat server.

Wechat provide OAuth2.0 authentication method `wechat_oauth2`, possible the easiest way, for the user perfer using devise style authorization gems, [omniauth-wechat-oauth2](https://github.com/skinnyworm/omniauth-wechat-oauth2) can be a good option.

There is official [weui](https://github.com/weui/weui), which corresponding Rails gems called [weui-rails](https://github.com/Eric-Guo/weui-rails) available, if you prefer following the same UI design as wechat.

For web page only wechat application, using [`wechat_api`](#wechat_api---rails-controller-wechat-api), which only contain web feature compare with traditional message type [`wechat_responder`](#wechat_responder---rails-responder-controller-dsl). 

There is a more complete [wechat-starter](https://github.com/goofansu/wechat-starter) demo available, even include the payment SDK feature.

## Installation

Using `gem install`

```
gem install "wechat"
```

Or add to your app's `Gemfile`:

```
gem 'wechat'
```

Run the following command to install it:

```console
bundle install
```

Run the generator:

```console
rails generate wechat:install
```

`rails g wechat:install` will generated the initial `wechat.yml` configuration, example wechat controller and corresponding routes.

Enable session record:

```console
rails g wechat:session
rake db:migrate
```

Enable session record will generate two files in Rails folder,  User can add more column fields in *wechat_session* table and add declare to link to users table, it's also possible to store data directly in **hash_store**. if you are using PostgreSQL, using [hstore](http://guides.rubyonrails.org/active_record_postgresql.html#hstore)/json maybe better, but the best way is still add dedicate column to record the data, the Rails way.

Using Redis to store wechat token and ticket:

```console
rails g wechat:redis_store
```

Redis store support Rails application running in multi-server, no need to enable it if your Rails application running in one server only, the wechat command won't read the token/ticket store in Redis.

## Configuration

#### Configure for wechat for first time

Make sure finish all the setup on rails side first, then submit to wechat. Otherwise, wechat will raise error.

URL address for wechat by running `rails g wechat:install` is `http://your-server.com/wechat`

How to setup appid/corpid and secret see below section.

#### Configure for command line

To using `wechat` command solely, needs created configure file `~/.wechat.yml` and including below content for public account. the access_token will be write as a file.

```
appid: "my_appid"
secret: "my_secret"
access_token: "/var/tmp/wechat_access_token"
```

For enterprise account, need using `corpid` instead of `appid` as enterprise account support multiply application (Tencent called agent) in one enterprise account. Obtain the `corpsecret` is a little tricky, must created at management mode->privilege setting and create any of management group to obtain. Due to Tencent currently only provide Chinese interface for they management console, it's highly recommend you find a college knowing Mandarin to help you to obtain.

Windows user need store `.wechat.yml` at `C:/Users/[user_name]/` (replace your user name), also be caution the direction of folder separator.

```
corpid: "my_appid"
corpsecret: "my_secret"
agentid: 1 # Integer, which can be obtain from application, settings
access_token: "C:/Users/[user_name]/wechat_access_token"
```

#### Configure for Rails

Rails configuration files support different environment similar to database.yml, after running `rails generate wechat:install` you can find configuration files at `config/wechat.yml`

Public account congfigure example：

```
default: &default
  appid: "app_id"
  secret: "app_secret"
  token:  "app_token"
  access_token: "/var/tmp/wechat_access_token"
  jsapi_ticket: "/var/tmp/wechat_jsapi_ticket"

production:
  appid: <%= ENV['WECHAT_APPID'] %>
  secret: <%= ENV['WECHAT_APP_SECRET'] %>
  token:   <%= ENV['WECHAT_TOKEN'] %>
  access_token: <%= ENV['WECHAT_ACCESS_TOKEN'] %>
  jsapi_ticket: <%= ENV['WECHAT_JSAPI_TICKET'] %>
  oauth2_cookie_duration: <%= ENV['WECHAT_OAUTH2_COOKIE_DURATION'] %> # seconds

development:
  <<: *default
  trusted_domain_fullname: "http://your_dev.proxy.qqbrowser.cc"

test:
  <<: *default
```

Although it's optional for public account, but highly recommend to enable encrypt mode by add below two items to `wechat.yml`


```
default: &default
  encrypt_mode: true
  encoding_aes_key:  "my_encoding_aes_key"
```

Enterprise account must using encrypt mode (`encrypt_mode: true` is default on, no need configure).

The `token` and `encoding_aes_key` can be obtain from management console -> one of the agent application -> Mode selection, select callback mode and get/set.

```
default: &default
  corpid: "corpid"
  corpsecret: "corpsecret"
  agentid:  1
  access_token: "C:/Users/[user_name]/wechat_access_token"
  token:    ""
  encoding_aes_key:  ""
  jsapi_ticket: "C:/Users/[user_name]/wechat_jsapi_ticket"
  
production:
  corpid:     <%= ENV['WECHAT_CORPID'] %>
  corpsecret: <%= ENV['WECHAT_CORPSECRET'] %>
  agentid:    <%= ENV['WECHAT_AGENTID'] %>
  access_token:  <%= ENV['WECHAT_ACCESS_TOKEN'] %>
  token:      <%= ENV['WECHAT_TOKEN'] %>
  timeout:    30,
  skip_verify_ssl: true # not recommend
  encoding_aes_key:  <%= ENV['WECHAT_ENCODING_AES_KEY'] %>
  jsapi_ticket: <%= ENV['WECHAT_JSAPI_TICKET'] %>
  oauth2_cookie_duration: <%= ENV['WECHAT_OAUTH2_COOKIE_DURATION'] %>

development:
  <<: *default
  trusted_domain_fullname: "http://your_dev.proxy.qqbrowser.cc"

test:
  <<: *default
```

##### Configure priority

Running `wechat` command in the root folder of Rails application will using the Rails configuration first (`default` section), if can not find it, will relay on `~\.wechat.yml`, such behavior enable manage more wechat public account and enterprise account without changing your home `~\.wechat.yml` file.

##### Wechat server timeout setting

Stability various even for Tencent wechat server, so setting a long timeout may needed, default is 20 seconds if not set.

##### Skip the SSL verification

SSL Certification can also be corrupted by some reason in China, [it's reported](http://qydev.weixin.qq.com/qa/index.php?qa=11037) and if it's happen to you, can setting `skip_verify_ssl: true`. (not recommend)  

#### Configure individual responder with different appid

Sometime, you may want to hosting more than one enterprise/public wechat account in one Rails application, so you can given those configuration info when calling `wechat_responder` or `wechat_api`

```ruby
class WechatFirstController < ActionController::Base
   wechat_responder appid: "app1", secret: "secret1", token: "token1", access_token: Rails.root.join("tmp/access_token1")

   on :text, with:"help", respond: "help content"
end
```

#### JS-SDK helper

JS-SDK enable you control Wechat App behavior in html, by inject a config signature, helper `wechat_config_js` do that in more simple way:

To make wechat_config_js works, you need put [`wechat_api`](#wechat_api---rails-controller-wechat-api) or [`wechat_responder`](#wechat_responder---rails-responder-controller-dsl) at controller first.

```erb
<body>
<%= wechat_config_js debug: false, api: %w(hideMenuItems closeWindow) -%>
<script type="application/javascript">
  wx.ready(function() {
      wx.hideOptionMenu();
  });
</script>
<a href="javascript:wx.closeWindow();">Close</a>
</body>
```

Configure the `trusted_domain_fullname` if you are in development mode and app running behind a reverse proxy server, otherwise wechat gem can not get the correct url to be signature later.

#### OAuth2.0 authentication

For public account, below code will get flollowing user's info.

```ruby
class CartController < ActionController::Base
  wechat_api
  def index
    wechat_oauth2 do |openid|
      @current_user = User.find_by(wechat_openid: openid)
      @articles = @current_user.articles
    end
  end
end
```

For enterprise account, below code will get enterprise member's userinfo.

```ruby
class WechatsController < ActionController::Base
  layout 'wechat'
  wechat_responder
  def apply_new
    wechat_oauth2 do |userid|
      @current_user = User.find_by(wechat_userid: userid)
      @apply = Apply.new
      @apply.user_id = @current_user.id
    end
  end
end
```

`wechat_oauth2` already implement the necessory OAuth2.0 and cookie logic. userid defined as the enterprise member UserID. openid defined as the user who following the public account, also notice openid will be different for the same user for different following public account.

Notice: If you use `wechat_responder` in your controller, you cannot use `create` and `show` action in your controller, otherwise will throw errors.


## The API privilege

wechat gems won't handle any privilege exception. (except token time out, but it's not important to you as it's auto retry/recovery in gems internally), but Tencent will control a lot of privilege based on your public account type and certification, more info, please reference [official document](http://mp.weixin.qq.com/wiki/7/2d301d4b757dedc333b9a9854b457b47.html).

## Command line mode

The available API is different between public account and enterprise account, so wechat gems provide different set of command.

Feel safe if you can not read Chinese in the comments, it's keep there in order to copy & find in official document more easier.

#### Public account command line

```
$ wechat
Wechat commands:
  wechat callbackip                                        # 获取微信服务器IP地址
  wechat custom_image [OPENID, IMAGE_PATH]                 # 发送图片客服消息
  wechat custom_music [OPENID, THUMBNAIL_PATH, MUSIC_URL]  # 发送音乐客服消息
  wechat custom_news [OPENID, NEWS_YAML_PATH]              # 发送图文客服消息
  wechat custom_text [OPENID, TEXT_MESSAGE]                # 发送文字客服消息
  wechat custom_video [OPENID, VIDEO_PATH]                 # 发送视频客服消息
  wechat custom_voice [OPENID, VOICE_PATH]                 # 发送语音客服消息
  wechat customservice_getonlinekflist                     # 获取在线客服接待信息  
  wechat group_create [GROUP_NAME]                         # 创建分组
  wechat group_delete [GROUP_ID]                           # 删除分组
  wechat group_update [GROUP_ID, NEW_GROUP_NAME]           # 修改分组名
  wechat groups                                            # 查询所有分组
  wechat material [MEDIA_ID, PATH]                         # 永久媒体下载
  wechat material_add [MEDIA_TYPE, PATH]                   # 永久媒体上传
  wechat material_count                                    # 获取永久素材总数
  wechat material_delete [MEDIA_ID]                        # 删除永久素材
  wechat material_list [TYPE, OFFSET, COUNT]               # 获取永久素材列表
  wechat media [MEDIA_ID, PATH]                            # 媒体下载
  wechat media_create [MEDIA_TYPE, PATH]                   # 媒体上传
  wechat media_uploadimg [IMAGE_PATH]                      # 上传图文消息内的图片
  wechat menu                                              # 当前菜单
  wechat menu_addconditional [CONDITIONAL_MENU_YAML_PATH]  # 创建个性化菜单  
  wechat menu_create [MENU_YAML_PATH]                      # 创建菜单
  wechat menu_delconditional [MENU_ID]                     # 删除个性化菜单  
  wechat menu_delete                                       # 删除菜单
  wechat menu_trymatch [USER_ID]                           # 测试个性化菜单匹配结果  
  wechat qrcode_create_limit_scene [SCENE_ID_OR_STR]       # 请求永久二维码
  wechat qrcode_create_scene [SCENE_ID, EXPIRE_SECONDS]    # 请求临时二维码
  wechat qrcode_download [TICKET, QR_CODE_PIC_PATH]        # 通过ticket下载二维码
  wechat short_url [LONG_URL]                              # 长链接转短链接
  wechat template_message [OPENID, TEMPLATE_YAML_PATH]     # 模板消息接口
  wechat user [OPEN_ID]                                    # 获取用户基本信息
  wechat user_batchget [OPEN_ID_LIST]                      # 批量获取用户基本信息  
  wechat user_change_group [OPEN_ID, TO_GROUP_ID]          # 移动用户分组
  wechat user_group [OPEN_ID]                              # 查询用户所在分组
  wechat user_update_remark [OPEN_ID, REMARK]              # 设置备注名
  wechat users                                             # 关注者列表
```

#### Enterprise account command line
```
$ wechat
Wechat commands:
  wechat agent [AGENT_ID]                                  # 获取企业号应用详情
  wechat agent_list                                        # 获取应用概况列表
  wechat batch_job_result [JOB_ID]                         # 获取异步任务结果
  wechat batch_replaceparty [BATCH_PARTY_CSV_MEDIA_ID]     # 全量覆盖部门
  wechat batch_replaceuser [BATCH_USER_CSV_MEDIA_ID]       # 全量覆盖成员
  wechat batch_syncuser [SYNC_USER_CSV_MEDIA_ID]           # 增量更新成员
  wechat callbackip                                        # 获取微信服务器IP地址
  wechat convert_to_openid [USER_ID]                       # userid转换成openid
  wechat custom_image [OPENID, IMAGE_PATH]                 # 发送图片客服消息
  wechat custom_music [OPENID, THUMBNAIL_PATH, MUSIC_URL]  # 发送音乐客服消息
  wechat custom_news [OPENID, NEWS_YAML_PATH]              # 发送图文客服消息
  wechat custom_text [OPENID, TEXT_MESSAGE]                # 发送文字客服消息
  wechat custom_video [OPENID, VIDEO_PATH]                 # 发送视频客服消息
  wechat custom_voice [OPENID, VOICE_PATH]                 # 发送语音客服消息
  wechat department [DEPARTMENT_ID]                        # 获取部门列表
  wechat department_create [NAME, PARENT_ID]               # 创建部门
  wechat department_delete [DEPARTMENT_ID]                 # 删除部门
  wechat department_update [DEPARTMENT_ID, NAME]           # 更新部门
  wechat invite_user [USER_ID]                             # 邀请成员关注
  wechat material [MEDIA_ID, PATH]                         # 永久媒体下载
  wechat material_add [MEDIA_TYPE, PATH]                   # 永久媒体上传
  wechat material_count                                    # 获取永久素材总数
  wechat material_delete [MEDIA_ID]                        # 删除永久素材
  wechat material_list [TYPE, OFFSET, COUNT]               # 获取永久素材列表
  wechat media [MEDIA_ID, PATH]                            # 媒体下载
  wechat media_create [MEDIA_TYPE, PATH]                   # 媒体上传
  wechat media_uploadimg [IMAGE_PATH]                      # 上传图文消息内的图片
  wechat menu                                              # 当前菜单
  wechat menu_create [MENU_YAML_PATH]                      # 创建菜单
  wechat menu_delete                                       # 删除菜单
  wechat message_send [OPENID, TEXT_MESSAGE]               # 发送文字消息
  wechat qrcode_download [TICKET, QR_CODE_PIC_PATH]        # 通过ticket下载二维码
  wechat tag [TAG_ID]                                      # 获取标签成员
  wechat tag_add_department [TAG_ID, PARTY_IDS]            # 增加标签部门
  wechat tag_add_user [TAG_ID, USER_IDS]                   # 增加标签成员
  wechat tag_create [TAGNAME, TAG_ID]                      # 创建标签
  wechat tag_del_department [TAG_ID, PARTY_IDS]            # 删除标签部门
  wechat tag_del_user [TAG_ID, USER_IDS]                   # 删除标签成员
  wechat tag_delete [TAG_ID]                               # 删除标签
  wechat tag_update [TAG_ID, TAGNAME]                      # 更新标签名字
  wechat tags                                              # 获取标签列表
  wechat template_message [OPENID, TEMPLATE_YAML_PATH]     # 模板消息接口
  wechat upload_replaceparty [BATCH_PARTY_CSV_PATH]        # 上传文件方式全量覆盖部门
  wechat upload_replaceuser [BATCH_USER_CSV_PATH]          # 上传文件方式全量覆盖成员
  wechat user [OPEN_ID]                                    # 获取用户基本信息
  wechat user_batchdelete [USER_ID_LIST]                   # 批量删除成员
  wechat user_delete [USER_ID]                             # 删除成员
  wechat user_list [DEPARTMENT_ID]                         # 获取部门成员详情
  wechat user_simplelist [DEPARTMENT_ID]                   # 获取部门成员
  wechat user_update_remark [OPEN_ID, REMARK]              # 设置备注名
```

### Command line usage demo (partially)

##### Fetch all users open id

```
$ wechat users

{"total"=>4, "count"=>4, "data"=>{"openid"=>["oCfEht9***********", "oCfEhtwqa***********", "oCfEht9oMCqGo***********", "oCfEht_81H5o2***********"]}, "next_openid"=>"oCfEht_81H5o2***********"}

```

##### Fetch user info

```
$ wechat user "oCfEht9***********"

{"subscribe"=>1, "openid"=>"oCfEht9***********", "nickname"=>"Nickname", "sex"=>1, "language"=>"zh_CN", "city"=>"徐汇", "province"=>"上海", "country"=>"中国", "headimgurl"=>"http://wx.qlogo.cn/mmopen/ajNVdqHZLLBd0SG8NjV3UpXZuiaGGPDcaKHebTKiaTyof*********/0", "subscribe_time"=>1395715239}

```

##### Fetch menu
```
$ wechat menu

{"menu"=>{"button"=>[{"type"=>"view", "name"=>"保护的", "url"=>"http://***/protected", "sub_button"=>[]}, {"type"=>"view", "name"=>"公开的", "url"=>"http://***", "sub_button"=>[]}]}}

```

##### Menu create

Running command `rails g wechat:menu` to generate a menu defination yaml file:

```
button:
 -
  name: "Want"
  sub_button:
   -
    type: "scancode_waitmsg"
    name: "绑定用餐二维码"
    key: "BINDING_QR_CODE"
   -
    type: "click"
    name: "预订午餐"
    key:  "BOOK_LUNCH"
   -
    type: "click"
    name: "预订晚餐"
    key:  "BOOK_DINNER"
 -
  name: "Query"
  sub_button:
   -
    type: "click"
    name: "进出记录"
    key:  "BADGE_IN_OUT"
   -
    type: "click"
    name: "年假余额"
    key:  "ANNUAL_LEAVE"
 -
  type: "view"
  name: "About"
  url:  "http://blog.cloud-mes.com/"
```

Running below command to upload the menu:

```
$ wechat menu_create menu.yaml
```

Caution: make sure you having management privilege for those application， otherwise will got [60011](http://qydev.weixin.qq.com/wiki/index.php?title=%E5%85%A8%E5%B1%80%E8%BF%94%E5%9B%9E%E7%A0%81%E8%AF%B4%E6%98%8E) error.

##### Sent custom news


Sending custom_news should also defined as a yaml file, like `articles.yml`

```
articles:
 -
  title: "习近平在布鲁日欧洲学院演讲"
  description: "新华网比利时布鲁日4月1日电 国家主席习近平1日在比利时布鲁日欧洲学院发表重要演讲"
  url: "http://news.sina.com.cn/c/2014-04-01/232629843387.shtml"
  pic_url: "http://i3.sinaimg.cn/dy/c/2014-04-01/1396366518_bYays1.jpg"
```

After that, can running command:

```
$ wechat custom_news oCfEht9oM*********** articles.yml

```

##### Sent template message

Sending template message via yaml file similar too, defined `template.yml` and content is just the template content.

```
template:
  template_id: "o64KQ62_xxxxxxxxxxxxxxx-Qz-MlNcRKteq8"
  url: "http://weixin.qq.com/download"
  topcolor: "#FF0000"
  data:
    first:
      value: "Hello, you successfully registed"
      color: "#0A0A0A"      
    keynote1:
      value: "5km Health Running"
      color: "#CCCCCC"      
    keynote2:
      value: "2014-09-16"
      color: "#CCCCCC"     
    keynote3:
      value: "Centry Park, Pudong, Shanghai"
      color: "#CCCCCC"                 
    remark:
      value: "Welcome back"
      color: "#173177"          

```

After that, can running command:

```
$ wechat template_message oCfEht9oM*********** template.yml
```

In code:

```ruby
template = YAML.load(File.read(template_yaml_path)).symbolize_keys
Wechat.api.template_message_send Wechat::Message.to(openid).template(template)
```

If using wechat_api or wechat_responder in Controller, can alse use wechat as shortcut(Support multi account):

```ruby
template = YAML.load(File.read(template_yaml_path)).symbolize_keys
wechat.template_message_send Wechat::Message.to(openid).template(template)
```

## wechat_api - Rails Controller Wechat API

Although user can always access all wechat feature via Wechat.api, but it's much more recommand to using `wechat` directly in controller. It's not only mandatory require if you plan to support multi-account, also help to seperate the wechat specific logic from the model layer.

```ruby
class WechatReportsController < ApplicationController
  wechat_api
  layout 'wechat'

  def index
    @lots = Lot.with_preloading.wip_lot
  end
end
```

## wechat_responder - Rails Responder Controller DSL

In order to responding the message user sent, Rails developer need create a wechat responder controller and defined the routing in `routes.rb`

```ruby
  resource :wechat, only:[:show, :create]
```

So the ActionController should defined like below:

```ruby
class WechatsController < ActionController::Base
  wechat_responder

  # default text responder when no other match
  on :text do |request, content|
    request.reply.text "echo: #{content}" # Just echo
  end

  # When receive 'help', will trigger this responder
  on :text, with: 'help' do |request|
    request.reply.text 'help content'
  end

  # When receive '<n>news', will match and will got count as <n> as parameter
  on :text, with: /^(\d+) news$/ do |request, count|
    # Wechat article can only contain max 10 items, large than 10 will dropped.
    news = (1..count.to_i).each_with_object([]) { |n, memo| memo << { title: 'News title', content: "No. #{n} news content" } }
    request.reply.news(news) do |article, n, index| # article is return object
      article.item title: "#{index} #{n[:title]}", description: n[:content], pic_url: 'http://www.baidu.com/img/bdlogo.gif', url: 'http://www.baidu.com/'
    end
  end

  on :event, with: 'subscribe' do |request|
    request.reply.text "#{request[:FromUserName]} subscribe now"
  end

  # When unsubscribe user scan qrcode qrscene_xxxxxx to subscribe in public account
  # notice user will subscribe public account at same time, so wechat won't trigger subscribe event any more
  on :scan, with: 'qrscene_xxxxxx' do |request, ticket|
    request.reply.text "Unsubscribe user #{request[:FromUserName]} Ticket #{ticket}"
  end

  # When subscribe user scan scene_id in public account
  on :scan, with: 'scene_id' do |request, ticket|
    request.reply.text "Subscribe user #{request[:FromUserName]} Ticket #{ticket}"
  end

  # When no any on :scan responder can match subscribe user scaned scene_id
  on :event, with: 'scan' do |request|
    if request[:EventKey].present?
      request.reply.text "event scan got EventKey #{request[:EventKey]} Ticket #{request[:Ticket]}"
    end
  end

  # When enterprise user press menu BINDING_QR_CODE and success to scan bar code
  on :scan, with: 'BINDING_QR_CODE' do |request, scan_result, scan_type|
    request.reply.text "User #{request[:FromUserName]} ScanResult #{scan_result} ScanType #{scan_type}"
  end

  # Except QR code, wechat can also scan CODE_39 bar code in enterprise account
  on :scan, with: 'BINDING_BARCODE' do |message, scan_result|
    if scan_result.start_with? 'CODE_39,'
      message.reply.text "User: #{message[:FromUserName]} scan barcode, result is #{scan_result.split(',')[1]}"
    end
  end

  # When user click the menu button
  on :click, with: 'BOOK_LUNCH' do |request, key|
    request.reply.text "User: #{request[:FromUserName]} click #{key}"
  end

  # When user view URL in the menu button
  on :view, with: 'http://wechat.somewhere.com/view_url' do |request, view|
    request.reply.text "#{request[:FromUserName]} view #{view}"
  end

  # When user sent the imsage
  on :image do |request|
    request.reply.image(request[:MediaId]) # Echo the sent image to user
  end

  # When user sent the voice
  on :voice do |request|
    request.reply.voice(request[:MediaId]) # Echo the sent voice to user
  end

  # When user sent the video
  on :video do |request|
    nickname = wechat.user(request[:FromUserName])['nickname'] # Call wechat api to get sender nickname
    request.reply.video(request[:MediaId], title: 'Echo', description: "Got #{nickname} sent video") # Echo the sent video to user
  end

  # When user sent location
  on :location do |request|
    request.reply.text("Latitude: #{request[:Latitude]} Longitude: #{request[:Longitude]} Precision: #{request[:Precision]}")
  end

  on :event, with: 'unsubscribe' do |request|
    request.reply.success # user can not receive this message
  end

  # When user enter the app / agent app
  on :event, with: 'enter_agent' do |request|
    request.reply.text "#{request[:FromUserName]} enter agent app now"
  end

  # When batch job create/update user (incremental) finished.
  on :batch_job, with: 'sync_user' do |request, batch_job|
    request.reply.text "sync_user job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
  end

  # When batch job replace user (full sync) finished.
  on :batch_job, with: 'replace_user' do |request, batch_job|
    request.reply.text "replace_user job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
  end

  # When batch job invent user finished.
  on :batch_job, with: 'invite_user' do |request, batch_job|
    request.reply.text "invite_user job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
  end

  # When batch job replace department (full sync) finished.
  on :batch_job, with: 'replace_party' do |request, batch_job|
    request.reply.text "replace_party job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
  end

  # Any not match above will fail to below
  on :fallback, respond: 'fallback message'
end
```

So the importent statement is only `wechat_responder`, all other is just a DSL:

```
on <message_type> do |message|
 message.reply.text "some text"
end
```

The block code will be running to responding user's message.


Below is current supported message_type:

- :text  text message, using `:with` to match text content like `on(:text, with:'help'){|message, content| ...}`
- :image image message
- :voice voice message
- :shortvideo shortvideo message
- :video video message
- :link  link message
- :event event message, using `:with` to match particular event, support regular expression match similr to text message.
- :click virtual event message, wechat still sent event message，but gems will mapping to menu click event.
- :view  virtual view message, wechat still sent event message，but gems will mapping to menu view page event.
- :scan  virtual scan message, wechat still sent event message, but gems will mapping on scan event
- :batch_job  virtual batch job message
- :location virtual location message
- :fallback default message, when no other responder can handle incoming messsage, will using fallback to handle

### Transfer to customer service

```ruby
class WechatsController < ActionController::Base
  # When no other responder can handle incoming message, will transfer to human customer service.
  on :fallback do |message|
    message.reply.transfer_customer_service
  end
end
```

Caution: do not setting default text responder if you want to using [multiply human customer service](http://dkf.qq.com/), other will lead text message can not transfer.

### Notifications

* `wechat.responder.after_create` data include request<Wechat::Message> and response<Wechat::Message>.

Example:

```ruby
ActiveSupport::Notifications.subscribe('wechat.responder.after_create') do |name, started, finished, unique_id, data|
  WechatLog.create request: data[:request], response: data[:response]
end
```

## Known Issue

* Sometime, enterprise account can not receive the menu message due to Tencent server can not resolved the DNS, so using IP as a callback URL more stable, but it's never happen for user sent text message.
* Enterprise batch replace users using a CSV format file, but if you using the download template directly, it's [not working](http://qydev.weixin.qq.com/qa/index.php?qa=13978), must open the CSV file in excel first, then save as CSV format again, seems Tencent only support Excel save as CSV file format.
* If you using unicorn behind nginx and https, you need setting `trusted_domain_fullname` and point to https, other will got http and lead invalid signature in the JS-SDK.

[version-badge]: https://badge.fury.io/rb/wechat.svg
[rubygems]: https://rubygems.org/gems/wechat
[travis-badge]: https://travis-ci.org/Eric-Guo/wechat.svg
[travis]: https://travis-ci.org/Eric-Guo/wechat
[codeclimate-badge]: https://codeclimate.com/github/Eric-Guo/wechat.png
[codeclimate]: https://codeclimate.com/github/Eric-Guo/wechat
[codecoverage-badge]: https://codeclimate.com/github/Eric-Guo/wechat/coverage.png
[codecoverage]: https://codeclimate.com/github/Eric-Guo/wechat/coverage
[gitter-badge]: https://badges.gitter.im/Join%20Chat.svg
[gitter]: https://gitter.im/Eric-Guo/wechat?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge
[issue-badge]: http://issuestats.com/github/Eric-Guo/wechat/badge/issue
[pr-badge]: http://issuestats.com/github/Eric-Guo/wechat/badge/pr
[issuestats]: http://issuestats.com/github/Eric-Guo/wechat
