class RemoveCommentsAndReplyNotifications < ActiveRecord::Migration[7.2]
  def up
    execute("DELETE FROM notifications WHERE kind = 1") if table_exists?(:notifications) && column_exists?(:notifications, :kind)

    remove_column :users, :email_notifications_enabled, :boolean if column_exists?(:users, :email_notifications_enabled)

    drop_table :comment_reply_notifications, if_exists: true
    drop_table :comments, if_exists: true
  end

  def down
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.string :author_name, null: false
      t.text :body, null: false
      t.boolean :approved, null: false, default: true
      t.references :user, foreign_key: true
      t.references :parent_comment, foreign_key: { to_table: :comments }
      t.timestamps
    end

    add_index :comments, :approved
    add_index :comments, :created_at

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

    add_column :users, :email_notifications_enabled, :boolean, null: false, default: false unless column_exists?(:users, :email_notifications_enabled)
  end
end
