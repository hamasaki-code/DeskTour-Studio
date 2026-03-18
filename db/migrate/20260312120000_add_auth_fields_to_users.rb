class AddAuthFieldsToUsers < ActiveRecord::Migration[7.2]
  class MigrationUser < ApplicationRecord
    self.table_name = "users"
  end

  def up
    add_column :users, :username, :string
    add_column :users, :password_digest, :string

    say_with_time "Backfilling usernames for existing users" do
      MigrationUser.reset_column_information

      MigrationUser.find_each do |user|
        base = user.name.to_s.parameterize(separator: "_").presence || "user"
        candidate = base
        suffix = 2

        while MigrationUser.where.not(id: user.id).exists?(username: candidate)
          candidate = "#{base}_#{suffix}"
          suffix += 1
        end

        user.update_columns(username: candidate)
      end
    end

    add_index :users, :username, unique: true
  end

  def down
    remove_index :users, :username
    remove_column :users, :password_digest
    remove_column :users, :username
  end
end
