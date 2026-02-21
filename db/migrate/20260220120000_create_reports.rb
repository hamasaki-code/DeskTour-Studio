class CreateReports < ActiveRecord::Migration[7.2]
  def change
    create_table :reports do |t|
      t.references :post, null: false, foreign_key: true
      t.references :reporter_user, null: true, foreign_key: { to_table: :users }
      t.string :reporter_token, null: false
      t.integer :reason, null: false, default: 0
      t.text :details
      t.integer :status, null: false, default: 0
      t.datetime :reviewed_at

      t.timestamps
    end

    add_index :reports, [ :post_id, :reporter_token ], unique: true
    add_index :reports, [ :post_id, :reporter_user_id ], unique: true, where: "reporter_user_id IS NOT NULL"
    add_index :reports, [ :reporter_token, :created_at ]
    add_index :reports, :status
    add_index :reports, :created_at
  end
end
