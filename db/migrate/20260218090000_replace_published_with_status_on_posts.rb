class ReplacePublishedWithStatusOnPosts < ActiveRecord::Migration[7.2]
  def up
    add_column :posts, :status, :integer, null: false, default: 0
    add_index :posts, :status

    execute <<~SQL
      UPDATE posts
      SET status = CASE
        WHEN published THEN 1
        ELSE 0
      END
    SQL

    remove_index :posts, :published if index_exists?(:posts, :published)
    remove_column :posts, :published
  end

  def down
    add_column :posts, :published, :boolean, null: false, default: true
    add_index :posts, :published

    execute <<~SQL
      UPDATE posts
      SET published = CASE
        WHEN status = 1 THEN TRUE
        ELSE FALSE
      END
    SQL

    remove_index :posts, :status if index_exists?(:posts, :status)
    remove_column :posts, :status
  end
end
