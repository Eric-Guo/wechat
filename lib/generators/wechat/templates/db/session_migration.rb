class CreateWechatSessions < ActiveRecord::Migration
  def change
    create_table :wechat_sessions do |t|
      t.string :openid, null: false
      t.string :hash_store
      t.timestamps null: false
    end
    add_index :wechat_sessions, :openid, unique: true
  end
end
