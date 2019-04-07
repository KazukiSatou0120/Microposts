class CreateRelationships < ActiveRecord::Migration[5.0]
  def change
    create_table :relationships do |t|
      t.references :user, foreign_key: true
      t.references :follow, foreign_key: { to_table: :users }
      #to_table~オプションによって外部キーとしてusersテーブルを参照する
      #t.referencesは別のテーブルを参照させるという意味
      t.timestamps
      
      t.index [:user_id, :follow_id], unique: true
      #user_idとfollow_idがペアで重複するものが保存されないようにするデータベースの設定。
    end
  end
end
