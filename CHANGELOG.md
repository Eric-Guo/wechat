# Changelog

## v0.11.11 (released at 09/13/2020)

* FIX: fix_load_controller_wechat not support MP type, by @Msms-NJ #281

## v0.11.10 (released at 09/02/2020)

* ADD: Wechat::MpApi.wxa_msg_sec_check.

## v0.11.9 (released at 04/29/2020)

* CHG: upgrade ssl_version to 1.2 by @paicha #276

## v0.11.8 (released at 03/09/2020)

* ADD: Wechat::CorpApi.news_message_send
* FIX: Wechat API Change material/get_material. reported by @0000sir #275

## v0.11.7 (released at 11/15/2019)

* ADD: Wechat::MpApi.subscribe_message_send. by @paicha #271
* FIX: FrozenError: can't modify frozen String. by @paicha #272
* New translatecontent support.

## v0.11.6 (released at 09/02/2019)

* Fix private method `next_migration_number` introduced at #267, by @zpdsky #270
* Give more clear warning about missing Rails in console. by @emtfe #268

## v0.11.5 (released at 08/30/2019)

* Add rubocop check in CI by @hophacker #267
* Support Rails 6 and Windows at #266

## v0.11.4 (released at 08/15/2019)

* rails 6 redirect_to use allow_other_host: true by @Chen-George-Zhen #263

## v0.11.3 (released at 07/02/2019)

* New addvoicetorecofortext and queryrecoresultfortext support.
* improve existing class detect by @3014zhangshuo #261
* new wxa_get_wxacode_unlimit API for miniapp by @paicha #260

## v0.11.2 (released at 05/08/2019)

* bugfix short_url to shorturl in wechat console tool by @yuanxinyu #259
* allow a message to be sent to a party (department) by @hophacker #256

## v0.11.1 (released at 03/01/2019)

* Let Message support markdown, text included; allow textcard btntxt to be omitted by @hophacker #251
* Enterprise account add checkin api by @hophacker #254
* Suggest use secret to differentiate different acces_tokens and tickets in Enterprise account by @hophacker #255


## v0.11.0 (released at 01/22/2019)

* Support Ruby 2.6.0 official
* Bump http gem to 4.0
* New clear quota API by @3014zhangshuo #244
* Wechat::Message support textcard by @hophacker #249
* New getusersummary and getusercumulate API #247

## v0.10.3 (released at 10/07/2018)

* Fix new share problem in iOS by @killernova #242

## v0.10.2 (released at 8/27/2018)

* Fix incompatible with Rails 5.2.1 by @chloerei #239

## v0.10.1 (released at 7/1/2018)

* Allow custom_message_send using Hash as message, previous only allow Wechat::Message. by @zuoliang0 and @fogisland #234

## v0.10.0 (released at 5/31/2018)

* Support multi wechat account at wechat_responder. by @tuliren #223
* Support wechat mini program apis & signature check. by @oiahoon #225
* Support sent template message with miniprogram. by @falm #228
* Fix request_content could be nil. by @paicha #229

## v0.9.0 (released at 4/15/2018)

* Support multi wechat account dynamically loading from DB. by @tuliren #222
* user_create API for enterprise account. #206
* Will ignore template_message_send error 43004 by @insub #214
* using template with version if the migration version available by @killernova #220
* Remove Deprecation oauth2_url
* Remove Ruby 2.2 support, add Rails 5.2 and http v3 support

## v0.8.12 (released at 9/13/2017)

* Read oauth2_state from ticket store every time to avoid invalid oauth2_state by @xiewenwei #196

## v0.8.11 (released at 7/25/2017)

* oauth2 state code not refresh at the same time of jsapi tickets refresh bug, many thanks @xiewenwei #192
* Add string type scene support for qrcode_create_scene. by @libuchao #191

## v0.8.10 (released at 6/19/2017)

* fix material_delete correctly.

## v0.8.9 (released at 6/18/2017)

* wechat material_delete failed to work, thanks @Victorialice report #78

## v0.8.8 (released at 5/18/2017)

* Better support multiple account. by @xiewenwei #187
* Allow load figaro via RAILS_ENV. by @goofansu #186

## v0.8.7 (released at 4/23/2017)

* Support new wxa_get_wxacode API for miniapp.
* Add InvalidCredentialError, support audio/amr, voice/speex as file and text/plain as json. by @acenqiu #184

## v0.8.6 (released at 3/17/2017)

* Support Rails 5.1 officially.
* make sure the formfile can be created outside. by @mechiland #181

## v0.8.5 (released at 3/14/2017)

* Support mass send API #176
* Support new media_hq API
* Support new createwxaqrcode API for miniapp
* Fix wechat_responder not proper injected in rails 5 API #165
* parse response support XML return, by @zhangbin #167
* WeChat only allow 8 article per one news, by @kikyous #175
* Store token at cookies, by @jstdoit #174

## v0.8.4 (released at 1/12/2017)

* Support Ruby 2.4.0
* Add support of Enterprise RedPacket API, by @zhangbin #169

## v0.8.3 (released at 11/26/2016)

* Fix wechat template key has camelCase problem, by @RyanChenDji #159
* Fix long time of oauth2_state bug for wechat_oauth2 methods, by @IvanChou #162

## v0.8.2 (released at 11/2/2016)

* Bug which if not using multi-account but using web login.

## v0.8.1 (released at 11/2/2016)

* After allow sub controller using wechat_api, it's possible not initialise at first time. by @IvanChou #155
* Support web application login scope snsapi_login.
* Add unionid support for public account.
* Remove OpenId in Enterprise OAuth2 as it's not supported by Tecent.

## v0.8.0 (released at 10/24/2016)

* Complete support multi-wechat public account. by @xiewenwei #150
* Support loading configure value from Figaro if application.yml exist.

## v0.7.20 (released at 8/29/2016)

* Apply opt and config together when loading controller_wechat, to simplify wechat_responder params. by @bzhang443 #147

## v0.7.19 (released at 8/25/2016)

* Enterprise account now custom_image/voice/file works now. by @zymiboxpay #145
* Fix timeout setting no effective since introduct HTTP. found by @hsluo #74

## v0.7.18 (released at 8/21/2016)

* Support label_location message, similar to location event, but sent by user with Label. #144
* Add gem signature as additional security methods.

## v0.7.17 (released at 8/18/2016)

* Allow declare wechat_api at ApplicationController, but using wechat at sub controller. #104

## v0.7.16 (released at 7/27/2016)

* FIX: consider '' in params as equal with nil, in ControllerApi#wechat_public_oauth2, by @snow #135
* New tag API for public account, by @pynixwang #127
* fix SSLv3 error by use TLSv1_client, by @IvanChou #133

## v0.7.15 (released at 7/03/2016)

* RSpec testing case on Rails 5 now.
* Resolve Rails 5 ActionController::Parameters issue.

## v0.7.14 (released at 5/29/2016)

* Fix when access_token failed lead ticket can not refresh problem.
* Default duration should be 1 hours instead of 0 seconds for wechat_oauth2.
* New shorturl allowing convert from long URL to short.

## v0.7.13 (released at 5/14/2016)

* Wechat.config.oauth2_cookie_duration need convert to secondes, found by @gabrieltong #111

## v0.7.12 (released at 5/12/2016)

* Fix web_userinfo wrong URL, found by @gabrieltong #110

## v0.7.11 (released at 4/18/2016)

* To cover wrong release 0.7.10, nothing change

## v0.7.10 (released at 4/18/2016) (yanked)

## v0.7.9 (released at 4/12/2016)

* wechat_oauth2 support public account now.
* Refresh and store state on jsapi ticket, using it on oauth2_url to more secure.
* Remove extra sending payload in message template send json
* Allow setting oauth2_cookie_duration in config

## v0.7.8 (released at 3/31/2016)

* New wechat_api, similar to wechat_responder, but without messange handle DSL, support web page only wechat application
* New media_uploadimg API.
* New file type of Message.
* Improved multi account support per different controller.

## v0.7.7 (released at 3/18/2016)

* New wechat_oauth2, only support enterprise account still.
* fix 'skip_before_action :verify_authenticity_token' bug for v5.0.0.beta3 by @vkill #97
* Support Rails 3.2 again after support Rails 5.0, by @guange2015 #96

## v0.7.6 (released at 3/05/2016)

* Support wechat public account conditional menu. #95

## v0.7.5 (released at 2/21/2016)

* New wechat_config_js to simplify the Wechat jsapi config.
* Support sent shortvideo.

## v0.7.4 (released at 1/23/2016)

* Add Redis store token/ticket support, close #76, #60
* Rails 5 support without deprecate warning or other not necessory call. #82

## v0.7.3 (released at 1/19/2016)

* Allow transfer_customer_service to specific account.
* New customservice_getonlinekflist API.
* session support class WechatSession no need table_exists? methods exist.

## v0.7.2 (released at 1/18/2016)

* Optional session support by @zfben #81, #88, #91
* Replace after_wechat_response with Rails Nofications facility, by @zfben, original issue is #79
* New user_batchget API. #89
* Support Rails 3.2 again after support Rails 5.0. by @guange2015 #87
* Fetch setting from RAILS_ENV first, then fetch default. by @kikyous #85
* Warning not support on :scan with regular expression, reason see #84

## v0.7.1 (released at 1/11/2016)

* Fix after using http, upload file function break. #78
* Add callback function after_wechat_response support. by @zfben #79
* Should using department_id instead of departmentid at enterprise api: user_simplelist/user_list.

## v0.7.0 (released at 1/1/2016)

* Using [http](https://github.com/httprb/http) instead of rest-client for performance reason. (not support upload file yet)

## v0.6.10 (released at 1/17/2016)

* Support Rails 3.2 again after support Rails 5.0. by @guange2015 #87
* Fetch setting from RAILS_ENV first, then fetch default. by @kikyous #85
* Warning not support on :scan with regular expression. by @kikyous #84

## v0.6.9 (released at 1/6/2016)

* Fix token refresh bug on multi worker. #76
* Rewrite the token relative code to add more storage support in future.

## v0.6.8 (released at 12/25/2015)

* Support Rails 5.0.0.beta1.
* English README available
* Fix oauth2_url calling error, fix #75

## v0.6.7 (released at 12/18/2015)

* Add timeout configuration option, close #74
* New getuserinfo and oauth2_url to support getting FromUserName from web page.

## v0.6.6 (released at 12/15/2015)

* Add jsapi_ticket support for Enterprise Account
* Default generated WechatsController < ActionController::Base, as many Rails application may having #authenticate_user or #set_current_user in ApplicationController, so easily affect the first time using experience.
* New syntax `on :view, with: 'VIEW_URL'` support.
* New command `upload_replaceparty` which combine three sub command to make uploading department easier.
* New command `upload_replaceuser` which combine three sub command to make uploading user easier.

## v0.6.5 (released at 11/24/2015)

* Handle 48001 error if token is expire/not valid, close #71
* ApiLoader will do config reading and initialize the api instead of spreading the logic.

## v0.6.4 (released at 11/16/2015)

* Command mode now display different command set based on enterprise/public account setting
* Move config logic in command/wechat to ApiLoader class
* Unsubscribe can only reply plain text 'success' #68
* Fix 404 qrcode download problem, by @huangxiangdan #69

## v0.6.3 (released at 11/14/2015)

* Official testing and support public encrypt mode, also fix one cipher bug, many thanks to @hlltc #67
* hlltc report public account FILE_BASE no longer needs, clean code #67
* Media command line reflect recent Tecent json schema change. #67

## v0.6.2 (released at 11/05/2015)

* Tecent report location API changed, so change wechat gems also. #64

## v0.6.1 (released at 10/20/2015)

* Handle 40001, invalid credential, access_token is invalid or not latest hint # 57
* Support at Rails 4.2.1 wechat can not run #58

## v0.6.0 (released at 10/08/2015)

### Scan and Batch job are BREAK CHANGE!

* Scan 2D barcode using new syntax `on :scan, with: 'BINDING_QR_CODE' ` instead of `on :event, with: 'BINDING_QR_CODE' ` in previous version #55
  Which will fix can not using `on :event, with: "scan" ` problem
* Batch job using new syntax `on :batch_job, with: 'replace_user' `
instead of previous `on :event, with: 'replace_user' `.
* Click menu support new syntax `on :click, with: 'BOOK_LUNCH' `, but `on :event, with: 'BOOK_LUNCH' ` still supported. perfer `on :click` because it running faster and more nature expression.
* Wechat::Responder using Hash for new :client and :batch_job event, avoid time consuming Array match responder
* Fix refresh token not working problem under ruby 2.0.0 #54
* New department_update, user_batchdelete, convert_to_openid API

## v0.5.0 (released at 9/25/2015)

* Only relay on activesupport on run time, so will greatly improve wechat cli startup time
* Add rails generator support `rails g wechat:install`
* Add batch job support for enterprise account like batch create user/department, both API, callback responder and CLI
* Add material management API and CLI
* Add tag API and CLI for enterprise account
* Add QR code scene function for public account

## v0.4.2 (released at 9/7/2015)

* Fix wrong number of arguments at Wechat::Responder.on by using arity #47
* Fix can not access wechat method after using instance level context.
* Fix skip_verify_ssl parameter error.

## v0.4.1 (released at 9/6/2015)

* Limit news articles collection to 10, close #5
* Resolve the conflict with gem "responders" by @seamon #45

## v0.4.0 (released at 9/5/2015)

* Enable the verify SSL for enterprise mode by default, as security is more importent than speed, but still can switch off by configure
* Support scancode_push/scancode_waitmsg event.
* New API method can get wechat server IP list
* New API to query/create department/media/material
* Fix can not read token_file in mingw bug, which introduce at #43

## v0.3.0 (released at 8/30/2015)

* New user group management API
* Allow transfer to customer service on fallback. #42
* Read and write access_token properly using file locking, #43

## v0.2.0 (released at 8/27/2015)

* Add wechat enterprise account support
* Make responder execute in action context, by @lazing #15
* jsapi_ticket support, by @feitian124 #27
* Rename gems to wechat and ambitious to being #1 gems about development wechat. thanks Xiaoning transfer this gem name.
* Original gem `wechat-rails` author skinnyworm trasfer to Eric-Guo as maintainer

## v0.1.1

* Initial release from [wechat-rails](https://github.com/skinnyworm/wechat-rails).
