module Wechat
  module ControllerApi
    extend ActiveSupport::Concern

    module ClassMethods
      attr_accessor :wechat_api_client, :wechat_cfg_account, :token, :appid, :corpid, :agentid, :encrypt_mode, :timeout,
                    :skip_verify_ssl, :encoding_aes_key, :trusted_domain_fullname, :oauth2_cookie_duration
    end

    def wechat
      self.class.wechat # Make sure user can continue access wechat at instance level similar to class level
    end

    def wechat_oauth2(scope = 'snsapi_base', page_url = nil, &block)
      appid = self.class.corpid || self.class.appid || lambda do
        self.class.wechat # to initialize wechat_api_client at first time call wechat_oauth2
        self.class.corpid || self.class.appid
      end.call
      raise 'Can not get corpid or appid, so please configure it first to using wechat_oauth2' if appid.blank?

      wechat.jsapi_ticket.ticket if wechat.jsapi_ticket.oauth2_state.nil?
      oauth2_params = {
        appid: appid,
        redirect_uri: page_url,
        scope: scope,
        response_type: 'code',
        state: wechat.jsapi_ticket.oauth2_state
      }

      return generate_oauth2_url(oauth2_params) unless block_given?
      self.class.corpid ? wechat_corp_oauth2(oauth2_params, &block) : wechat_public_oauth2(oauth2_params, &block)
    end

    private

    def wechat_public_oauth2(oauth2_params)
      openid  = cookies.signed_or_encrypted[:we_openid]
      unionid = cookies.signed_or_encrypted[:we_unionid]
      if openid.present?
        yield openid, { 'openid' => openid, 'unionid' => unionid }
      elsif params[:code].present? && params[:state] == oauth2_params[:state]
        access_info = wechat.web_access_token(params[:code])
        cookies.signed_or_encrypted[:we_openid] = { value: access_info['openid'], expires: self.class.oauth2_cookie_duration.from_now }
        cookies.signed_or_encrypted[:we_unionid] = { value: access_info['unionid'], expires: self.class.oauth2_cookie_duration.from_now }
        yield access_info['openid'], access_info
      else
        redirect_to generate_oauth2_url(oauth2_params)
      end
    end

    def wechat_corp_oauth2(oauth2_params)
      userid   = cookies.signed_or_encrypted[:we_userid]
      deviceid = cookies.signed_or_encrypted[:we_deviceid]
      if userid.present? && deviceid.present?
        yield userid, { 'UserId' => userid, 'DeviceId' => deviceid }
      elsif params[:code].present? && params[:state] == oauth2_params[:state]
        userinfo = wechat.getuserinfo(params[:code])
        cookies.signed_or_encrypted[:we_userid] = { value: userinfo['UserId'], expires: self.class.oauth2_cookie_duration.from_now }
        cookies.signed_or_encrypted[:we_deviceid] = { value: userinfo['DeviceId'], expires: self.class.oauth2_cookie_duration.from_now }
        yield userinfo['UserId'], userinfo
      else
        redirect_to generate_oauth2_url(oauth2_params)
      end
    end

    def generate_oauth2_url(oauth2_params)
      if oauth2_params[:redirect_uri].blank?
        page_url = (td = self.class.trusted_domain_fullname) ? "#{td}#{request.original_fullpath}" : request.original_url
        safe_query = request.query_parameters.reject { |k, _| %w(code state access_token).include? k }.to_query
        oauth2_params[:redirect_uri] = page_url.sub(request.query_string, safe_query)
      end

      if oauth2_params[:scope] == 'snsapi_login'
        "https://open.weixin.qq.com/connect/qrconnect?#{oauth2_params.to_query}#wechat_redirect"
      else
        "https://open.weixin.qq.com/connect/oauth2/authorize?#{oauth2_params.to_query}#wechat_redirect"
      end
    end
  end
end
