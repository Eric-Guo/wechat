# Changelog

## v0.7.14

* New short_url allowing convert from long URL to short.

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
