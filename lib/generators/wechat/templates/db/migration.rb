class CreateWechatSessions < ActiveRecord::Migration
  def change
    create_table :wechat_sessions do |t|
      t.string :openid, null: false, index: true
      if connection.adapter_name.downcase.to_sym == :postgresql
        t.json :session_raw
      else
        t.string :session_raw
      end
      t.timestamps null: false
    end
  end
end
