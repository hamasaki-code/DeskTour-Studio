class CreateCommentReplyNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :comment_reply_notifications do |t|
      t.references :recipient_user, null: false, foreign_key: { to_table: :users }
      t.references :comment, null: false, foreign_key: true
      t.references :parent_comment, null: false, foreign_key: { to_table: :comments }
      t.integer :status, null: false, default: 0
      t.datetime :sent_at
      t.text :error_message

      t.timestamps
    end

    add_index :comment_reply_notifications, :created_at
    add_index :comment_reply_notifications, :status
    add_index :comment_reply_notifications, :comment_id, unique: true
  end
end
