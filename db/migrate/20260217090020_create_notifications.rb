class CreateNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications do |t|
      t.references :post, null: false, foreign_key: true
      t.integer :kind, null: false, default: 0
      t.string :message, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, :created_at
    add_index :notifications, :read_at
  end
end
