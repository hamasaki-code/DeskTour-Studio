class AddReplyNotificationSettingsToUsersAndComments < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :email, :string
    add_column :users, :email_notifications_enabled, :boolean, null: false, default: false
    add_index :users, :email

    add_reference :comments, :user, foreign_key: true
    add_reference :comments, :parent_comment, foreign_key: { to_table: :comments }
  end
end
