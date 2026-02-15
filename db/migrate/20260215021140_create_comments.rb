class CreateComments < ActiveRecord::Migration[7.2]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.string :author_name, null: false
      t.text :body, null: false
      t.boolean :approved, null: false, default: true

      t.timestamps
    end

    add_index :comments, :approved
    add_index :comments, :created_at
  end
end
