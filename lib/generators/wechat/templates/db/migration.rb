class CreateWechatLogs < ActiveRecord::Migration
  def change
    create_table :wechat_logs do |t|
      t.string :openid, null: false, index: true
      t.text :request_raw
      t.text :response_raw
      t.text :session_raw
      t.datetime :created_at, null: false
    end
  end
end
