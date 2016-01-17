class CreateWechatSessions < ActiveRecord::Migration
  def change
    create_table :wechat_sessions do |t|
      t.string :from_openid, null: false, index: true
      t.string :to_openid, null: false, index: true
      if connection.adapter_name.downcase.to_sym == :postgresql
        t.json :json_hash_raw
      else
        t.string :json_hash_raw
      end
      t.timestamps null: false
    end
    add_index :wechat_sessions, :openid, unique: true
  end
end
