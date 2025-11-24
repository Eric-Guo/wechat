# Changelog

## v1.1.0 (released at 2025-11-24)

* Feat: api wxa_get_user_risk_rank. by @leepood #327

## v1.0.1 (released at 2025-07-09)

* Fix after introduce httpx, status method not available for HTTPX::ErrorResponse bug
* Some Google Jules Refactor

## v1.0.0 (released at 2025-05-17)

* WECHAT_PROXY_URL should be writen with port, like `export WECHAT_PROXY_URL=http://127.0.0.1:6152`, since WECHAT_PROXY_PORT removed.
* Replace http with httpx, [reason](https://honeyryderchuck.gitlab.io/2023/10/15/state-of-ruby-http-clients-use-httpx.html)
* Feat: add account_type to WechatConfig. by @leepood #324

## v0.17.7 (released at 2025-03-02)

* Adding ostruct into its gemspec. Fix #323

## v0.17.6 (released at 2024-10-25)

* Support Rails 8.0 now

## v0.17.5 (released at 2024-10-25)

* Remove `serialize :hash_store` in template as it's cause too many issue in different rails version.

## v0.17.4 (released at 2024-08-13)

* Fix private API ActiveSupport::Deprecation.warn called in Rails 7.2

## v0.17.3 (released at 2024-01-04)

* Add New CorpApi batch_get_by_user and follow_user_list. by @leepood #321
* Use JSON.parse handle response.body directly. by @leepood #322

## v0.17.2 (released at 2023-12-30)

* Fix no need the message type restrictions. by @leepood #319

## v0.17.1 (released at 2023-07-28)

* Add Record based token support. by @CoolDrinELiu #315
* Add api shortlink.generate support. by @wikimo #316
* Add new api & Compatible with WeCom. by @leepood #317

## v0.17.0 yarked

## v0.16.2 (released at 2022-12-09)

* Drop support ruby 2.6 and allow ruby 3.2 will released psych v5.0.0. by @iuhoay #314

## v0.16.1 (released at 2022-07-20)

* Add api urllink.generate support. by @iuhoay #313
* Fix WARNING: Zeitwerk defines the constant ActionController after the directory

## v0.16.0 (released at 2022-06-06)

* Support wechat draft. #305
* Add environment variable for configuring http proxy to ignore IP address changes everytime after app deployment, by @Awlter #312
* Soft drop support for Ruby 2.6, because EOL time 12 Apr 2022.

## v0.15.1 (released at 2022-02-16)

* fix "Psych::BadAlias (Unknown alias: default)" in ruby 3.1.0 #309, reported by @otorain

## v0.15.0 (released at 2021-12-21)

* Add wechat message json format support, by @younthu #306
* Support Rails 7 in this version.
* Fix wechat command-line 1st attempt bug #307

## v0.14.0 (released at 2021-09-15)

* Add beta support for Conversation archive in WeCom, discuss at #303
* Avoid using 1.hour in early loading to improve Rails 6+ compatibility.

## v0.13.3 (released at 2021-06-18)

* material add video description by @zlei1 #301
* Allow using http v5

## v0.13.2 (released at 2021-04-21)

* New material_add_news API, by @zlei1 #300
* Support open_tag, by @xiajian2019 #299

## v0.13.1 (released at 2021-03-15)

* Fix MpApi initialize bug, by @hardywu #296

## v0.13.0 (released at 2021-03-03)

* Support zeitwerk only and Rails 6+ only.
* Support Ruby 2.6+ only.

Previous changelog see https://github.com/Eric-Guo/wechat/blob/master/CHANGELOG_OLD.md
