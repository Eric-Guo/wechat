WeChat [![Gem Version][version-badge]][rubygems] [![Build Status][travis-badge]][travis] [![Code Climate][codeclimate-badge]][codeclimate] [![Code Coverage][codecoverage-badge]][codecoverage]
======

[![Join the chat][gitter-badge]][gitter] [![Issue Stats][issue-badge]][issuestats] [![PR Stats][pr-badge]][issuestats]

WeChat gem 可以帮助开发者方便地在Rails环境中集成微信[公众平台](https://mp.weixin.qq.com/)和[企业平台](https://qy.weixin.qq.com)提供的服务，包括：

- 微信公众/企业平台[主动消息](http://qydev.weixin.qq.com/wiki/index.php?title=%E5%8F%91%E9%80%81%E6%B6%88%E6%81%AF)API（命令行和Web环境都可以使用）
- [回调消息](http://qydev.weixin.qq.com/wiki/index.php?title=%E6%8E%A5%E6%94%B6%E6%B6%88%E6%81%AF%E4%B8%8E%E4%BA%8B%E4%BB%B6)（必须运行Web服务器）
- [微信JS-SDK](http://qydev.weixin.qq.com/wiki/index.php?title=%E5%BE%AE%E4%BF%A1JS%E6%8E%A5%E5%8F%A3) config接口注入权限验证
- OAuth 2.0认证机制

命令行工具`wechat`可以调用各种无需web环境的API。同时也提供了Rails Controller的responder DSL, 可以帮助开发者方便地在Rails应用中集成微信的消息处理，包括主动推送的和被动响应的消息。

如果你的App还需要集成微信OAuth2.0, 你可以考虑[omniauth-wechat-oauth2](https://github.com/skinnyworm/omniauth-wechat-oauth2), 以便和devise集成，提供完整的用户认证。

如果你对如何制作微信网页UI没有灵感，可以参考官方的[weui](https://github.com/weui/weui)，针对Rails的Gem是[weui-rails](https://github.com/Eric-Guo/weui-rails)。


## 安装

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

运行`rails g wechat:install`后会自动生成wechat.yml配置，还有wechat controller及相关路由配置到当前Rails项目。


## 配置

#### 命令行程序的配置

要使用命令行程序，需要在home目录中创建一个`~/.wechat.yml`，包含以下内容。其中`access_token`是存放access_token的文件位置。

```
appid: "my_appid"
secret: "my_secret"
access_token: "/var/tmp/wechat_access_token"
```

Windows或者使用企业号，需要存放在`C:/Users/[user_name]/`下，其中corpid和corpsecret可以从企业号管理界面的设置->权限管理，通过新建任意一个管理组后获取。

```
corpid: "my_appid"
corpsecret: "my_secret"
agentid: 1 # 企业应用的id，整型。可在应用的设置页面查看
access_token: "C:/Users/[user_name]/wechat_access_token"
```

#### Rails 全局配置
Rails应用程序中，需要将配置文件放在`config/wechat.yml`，可以为不同environment创建不同的配置。

公众号配置示例：

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

development:
  <<: *default

test:
  <<: *default
```

公众号可选安全模式（加密模式），通过添加如下配置可开启加密模式。

```
default: &default
  encrypt_mode: true
  encoding_aes_key:  "my_encoding_aes_key"
```

企业号配置下必须使用加密模式，其中token和encoding_aes_key可以从企业号管理界面的应用中心->某个应用->模式选择，选择回调模式后获得。

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
  skip_verify_ssl: true
  encoding_aes_key:  <%= ENV['WECHAT_ENCODING_AES_KEY'] %>
  jsapi_ticket: <%= ENV['WECHAT_JSAPI_TICKET'] %>

development:
  <<: *default

test:
  <<: *default
```

##### 配置优先级

注意在Rails项目根目录下运行`wechat`命令行工具会优先使用`config/wechat.yml`中的`default`配置，如果失败则使用`~\.wechat.yml`中的配置，以便于在生产环境下管理多个微信账号应用。

##### 配置微信服务器超时

微信服务器有时请求会花很长时间，如果不配置，默认为20秒，可视情况配置。

##### 配置跳过SSL认证

Wechat服务器有报道曾出现[RestClient::SSLCertificateNotVerified](http://qydev.weixin.qq.com/qa/index.php?qa=11037)错误，此时可以选择关闭SSL验证。`skip_verify_ssl: true`

#### 为每个Responder配置不同的appid和secret

在个别情况下，单个Rails应用可能需要处理来自多个账号的消息，此时可以配置多个responder controller。

```ruby
class WechatFirstController < ActionController::Base
   wechat_responder appid: "app1", secret: "secret1", token: "token1", access_token: Rails.root.join("tmp/access_token1")

   on :text, with:"help", respond: "help content"
end
```

#### jssdk 支持

jssdk 使用前需通过config接口注入权限验证配置, 所需参数可以通过 signature 方法获取:

```ruby
WechatsController.wechat.jsapi_ticket.signature(request.original_url)
```

## 关于接口权限

wechat gems 内部不会检查权限。但因公众号类型不同，和微信服务器端通讯时，可能会被拒绝，详细权限控制可参考[官方文档](http://mp.weixin.qq.com/wiki/7/2d301d4b757dedc333b9a9854b457b47.html)。

## 使用命令行

根据企业号和公众号配置不同，wechat提供了的命令行命令。

#### 公众号命令行

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
  wechat menu                                              # 当前菜单
  wechat menu_create [MENU_YAML_PATH]                      # 创建菜单
  wechat menu_delete                                       # 删除菜单
  wechat oauth2_url [REDIRECT_URI]                         # 生成OAuth2.0验证URL
  wechat qrcode_create_limit_scene [SCENE_ID_OR_STR]       # 请求永久二维码
  wechat qrcode_create_scene [SCENE_ID, EXPIRE_SECONDS]    # 请求临时二维码
  wechat qrcode_download [TICKET, QR_CODE_PIC_PATH]        # 通过ticket下载二维码
  wechat template_message [OPENID, TEMPLATE_YAML_PATH]     # 模板消息接口
  wechat user [OPEN_ID]                                    # 获取用户基本信息
  wechat user_change_group [OPEN_ID, TO_GROUP_ID]          # 移动用户分组
  wechat user_group [OPEN_ID]                              # 查询用户所在分组
  wechat user_update_remark [OPEN_ID, REMARK]              # 设置备注名
  wechat users                                             # 关注者列表
```

#### 企业号命令行
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
  wechat menu                                              # 当前菜单
  wechat menu_create [MENU_YAML_PATH]                      # 创建菜单
  wechat menu_delete                                       # 删除菜单
  wechat message_send [OPENID, TEXT_MESSAGE]               # 发送文字消息
  wechat oauth2_url [REDIRECT_URI]                         # 生成OAuth2.0验证URL
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
  name: "我要"
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
  name: "查询"
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
  name: "关于"
  url:  "http://blog.cloud-mes.com/"
```

然后执行命令行，需确保设置，权限管理中有对此应用的管理权限，否则会报[60011](http://qydev.weixin.qq.com/wiki/index.php?title=%E5%85%A8%E5%B1%80%E8%BF%94%E5%9B%9E%E7%A0%81%E8%AF%B4%E6%98%8E)错。

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

##### 发送模板消息
需定义一个模板消息内容的yaml文件，比如
template.yml

```
template:
  template_id: "o64KQ62_xxxxxxxxxxxxxxx-Qz-MlNcRKteq8"
  url: "http://weixin.qq.com/download"
  topcolor: "#FF0000"
  data:
    first:
      value: "你好，你已报名成功"
      color: "#0A0A0A"      
    keynote1:
      value: "XX活动"
      color: "#CCCCCC"      
    keynote2:
      value: "2014年9月16日"
      color: "#CCCCCC"     
    keynote3:
      value: "上海徐家汇xxx城"
      color: "#CCCCCC"                 
    remark:
      value: "欢迎再次使用。"
      color: "#173177"          

```

然后执行命令行

```
$ wechat template_message oCfEht9oM*********** template.yml
```

## Rails Responder Controller DSL

为了在Rails app中响应用户的消息，开发者需要创建一个wechat responder controller. 首先在router中定义

```ruby
  resource :wechat, only:[:show, :create]
```

然后创建Controller class, 例如

```ruby
class WechatsController < ActionController::Base
  wechat_responder

  # 默认文字信息responder
  on :text do |request, content|
    request.reply.text "echo: #{content}" #Just echo
  end

  # 当请求的文字信息内容为'help'时, 使用这个responder处理
  on :text, with: 'help' do |request|
    request.reply.text 'help content' #回复帮助信息
  end

  # 当请求的文字信息内容为'<n>条新闻'时, 使用这个responder处理, 并将n作为第二个参数
  on :text, with: /^(\d+)条新闻$/ do |request, count|
    # 微信最多显示10条新闻，大于10条将只取前10条
    news = (1..count.to_i).each_with_object([]) { |n, memo| memo << { title: '新闻标题', content: "第#{n}条新闻的内容#{n.hash}" } }
    request.reply.news(news) do |article, n, index| # 回复"articles"
      article.item title: "#{index} #{n[:title]}", description: n[:content], pic_url: 'http://www.baidu.com/img/bdlogo.gif', url: 'http://www.baidu.com/'
    end
  end

  # 当用户加关注
  on :event, with: 'subscribe' do |request|
    request.reply.text "User #{request[:FromUserName]} subscribe now"
  end

  # 公众号收到未关注用户扫描qrscene_xxxxxx二维码时。注意此次扫描事件将不再引发上条的用户加关注事件
  on :scan, with: 'qrscene_xxxxxx' do |request, ticket|
    request.reply.text "Unsubscribe user #{request[:FromUserName]} Ticket #{ticket}"
  end

  # 公众号收到已关注用户扫描创建二维码的scene_id事件时
  on :scan, with: 'scene_id' do |request, ticket|
    request.reply.text "Subscribe user #{request[:FromUserName]} Ticket #{ticket}"
  end

  # 当没有任何on :scan事件处理已关注用户扫描的scene_id时
  on :event, with: 'scan' do |request|
    if request[:EventKey].present?
      request.reply.text "event scan got EventKey #{request[:EventKey]} Ticket #{request[:Ticket]}"
    end
  end

  # 企业号收到EventKey 为二维码扫描结果事件时
  on :scan, with: 'BINDING_QR_CODE' do |request, scan_result, scan_type|
    request.reply.text "User #{request[:FromUserName]} ScanResult #{scan_result} ScanType #{scan_type}"
  end

  # 企业号收到EventKey 为CODE 39码扫描结果事件时
  on :scan, with: 'BINDING_BARCODE' do |message, scan_result|
    if scan_result.start_with? 'CODE_39,'
      message.reply.text "User: #{message[:FromUserName]} scan barcode, result is #{scan_result.split(',')[1]}"
    end
  end

  # 当用户点击菜单时
  on :click, with: 'BOOK_LUNCH' do |request, key|
    request.reply.text "User: #{request[:FromUserName]} click #{key}"
  end

  # 当用户点击菜单时
  on :view, with: 'http://wechat.somewhere.com/view_url' do |request, view|
    request.reply.text "#{request[:FromUserName]} view #{view}"
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
    nickname = wechat.user(request[:FromUserName])['nickname'] #调用 api 获得发送者的nickname
    request.reply.video(request[:MediaId], title: '回声', description: "#{nickname}发来的视频请求") #直接视频返回给用户
  end

  # 处理上报地理位置事件
  on :location do |request|
    request.reply.text("Latitude: #{message[:Latitude]} Longitude: #{message[:Longitude]} Precision: #{message[:Precision]}")
  end

  # 当用户取消关注订阅
  on :event, with: 'unsubscribe' do |request|
    request.reply.success # user can not receive this message
  end

  # 成员进入应用的事件推送
  on :event, with: 'enter_agent' do |request|
    request.reply.text "#{request[:FromUserName]} enter agent app now"
  end

  # 当异步任务增量更新成员完成时推送
  on :batch_job, with: 'sync_user' do |request, batch_job|
    request.reply.text "job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
  end

  # 当异步任务全量覆盖成员完成时推送
  on :batch_job, with: 'replace_user' do |request, batch_job|
    request.reply.text "job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
  end

  # 当异步任务邀请成员关注完成时推送
  on :batch_job, with: 'invite_user' do |request, batch_job|
    request.reply.text "job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
  end

  # 当异步任务全量覆盖部门完成时推送
  on :batch_job, with: 'replace_party' do |request, batch_job|
    request.reply.text "job #{batch_job[:JobId]} finished, return code #{batch_job[:ErrCode]}, return message #{batch_job[:ErrMsg]}"
  end

  # 当无任何responder处理用户信息时,使用这个responder处理
  on :fallback, respond: 'fallback message'
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
- :link 响应链接消息
- :event 响应事件消息, 可以用`:with`参数来匹配事件类型
- :click 虚拟响应事件消息, 微信传入:event，但gem内部会单独处理
- :view 虚拟响应事件消息, 微信传入:event，但gem内部会单独处理
- :scan  虚拟响应事件消息
- :batch_job  虚拟响应事件消息
- :location 虚拟响应上报地理位置事件消息
- :fallback 默认响应，当收到的消息无法被其他responder响应时，会使用这个responder.

### 多客服消息转发

```ruby
class WechatsController < ActionController::Base
  # 当无任何responder处理用户信息时，转发至客服处理。
  on :fallback do |message|
	message.reply.transfer_customer_service
  end
end
```

注意设置了[多客服消息转发](http://dkf.qq.com/)后，不能再添加`默认文字信息responder`，否则文字消息将得不到转发。

### 通知

现支持以下通知：

* `wechat.responder.after_create` data 包含 request<Wechat::Message> 和 response<Wechat::Message>

使用示例：

```ruby
ActiveSupport::Notifications.subscribe('wechat.responder.after_create') do |name, started, finished, unique_id, data|
  WechatLog.create request: data[:request], response: data[:response]
end
```

## 已知问题

* 企业号接受菜单消息时，Wechat腾讯服务器无法解析部分域名，请使用IP绑定回调URL，用户的普通消息目前不受影响。
* 企业号全量覆盖成员使用的csv通讯录格式，直接将下载的模板导入[是不工作的](http://qydev.weixin.qq.com/qa/index.php?qa=13978)，必须使用Excel打开，然后另存为csv格式才会变成合法格式。


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
