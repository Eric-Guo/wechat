# Migration Example
#
# create_table :wechat_logs do |t|
#   t.string :openid, null: false, index: true
#   if connection.adapter_name.downcase.to_sym == :postgresql
#     t.json :request_raw
#     t.json :response_raw
#     t.json :session_raw
#   else
#     t.text :request_raw
#     t.text :response_raw
#     t.text :session_raw
#   end
#   t.datetime :created_at, null: false
# end

class WechatLog < ActiveRecord::Base
  def self.create_by_responder(req, res)
    create from_openid: req[:FromUserName], to_openid: req[:ToUserName], request: req, response: res, session: res.session
  end

  %i(request response session).each do |name|
    define_method name do
      raw = send(:"#{name}_raw")
      return {} if raw.blank?
      raw = JSON.parse(raw) unless ActiveRecord::Base.connection.adapter_name.downcase.to_sym == :postgresql
      raw.symbolize_keys
    end

    define_method :"#{name}=" do |obj|
      if ActiveRecord::Base.connection.adapter_name.downcase.to_sym == :postgresql
        self[:"#{name}_raw"] = obj.try :to_hash
      else
        self[:"#{name}_raw"] = obj.try:to_json
      end
    end
  end
end

ActiveSupport::Notifications.subscribe('wechat.responder.after_create') do |_name, _started, _finished, _unique_id, data|
  WechatLog.create_by_responder data[:request], data[:response]
end
