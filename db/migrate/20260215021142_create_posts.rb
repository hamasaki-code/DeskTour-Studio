class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :category
      t.string :theme
      t.string :tag_list
      t.integer :likes_count, null: false, default: 0
      t.boolean :published, null: false, default: true

      t.timestamps
    end

    add_index :posts, :published
    add_index :posts, :created_at
  end
end
