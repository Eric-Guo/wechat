module Wechat
  module ControllerApi
    extend ActiveSupport::Concern

    module ClassMethods
      attr_accessor :wechat, :token, :appid, :corpid, :agentid, :encrypt_mode, :timeout, :skip_verify_ssl, :encoding_aes_key, :trusted_domain_fullname
    end

    def wechat
      self.class.wechat # Make sure user can continue access wechat at instance level similar to class level
    end

    def wechat_oauth2(scope = 'snsapi_base', page_url = nil, &block)
      appid = self.class.corpid || self.class.appid
      page_url ||= if self.class.trusted_domain_fullname
                     "#{self.class.trusted_domain_fullname}#{request.original_fullpath}"
                   else
                     request.original_url
                   end
      redirect_uri = CGI.escape(page_url)
      oauth2_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{appid}&redirect_uri=#{redirect_uri}&response_type=code&scope=#{scope}&state=#{wechat.jsapi_ticket.oauth2_state}#wechat_redirect"

      return oauth2_url unless block_given?
      if self.class.corpid
        wechat_corp_oauth2(oauth2_url, &block)
      else
        wechat_public_oauth2(oauth2_url, &block)
      end
    end

    private

    def wechat_public_oauth2(scope, oauth2_url)
      raise 'Currently wechat_oauth2 only support public account yet.'
    end

    def wechat_corp_oauth2(oauth2_url)
      if cookies.signed_or_encrypted[:we_deviceid].blank? && params[:code].blank?
        redirect_to oauth2_url
      elsif cookies.signed_or_encrypted[:we_deviceid].blank? && params[:code].present? && params[:state] == wechat.jsapi_ticket.oauth2_state
        userinfo = wechat.getuserinfo(params[:code])
        cookies.signed_or_encrypted[:we_userid] = { value: userinfo['UserId'], expires: 1.hour.from_now }
        cookies.signed_or_encrypted[:we_deviceid] = { value: userinfo['DeviceId'], expires: 1.hour.from_now }
        cookies.signed_or_encrypted[:we_openid] = { value: userinfo['OpenId'], expires: 1.hour.from_now }
        yield userinfo['UserId'], userinfo
      else
        yield cookies.signed_or_encrypted[:we_userid], { 'UserId' => cookies.signed_or_encrypted[:we_userid],
                                                         'DeviceId' => cookies.signed_or_encrypted[:we_deviceid],
                                                         'OpenId' => cookies.signed_or_encrypted[:we_openid] }
      end
    end
  end
end
