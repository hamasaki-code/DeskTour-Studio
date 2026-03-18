class CreateSupportRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :support_requests do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :username
      t.string :subject, null: false
      t.text :message, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :support_requests, :status
    add_index :support_requests, :created_at
  end
end
