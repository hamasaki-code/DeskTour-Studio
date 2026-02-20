class AddUserAndOwnerTokenDigestToPosts < ActiveRecord::Migration[7.2]
  def change
    add_reference :posts, :user, null: false, foreign_key: true
    add_column :posts, :owner_token_digest, :string, null: false
    add_index :posts, :owner_token_digest
  end
end
