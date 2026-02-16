class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items do |t|
      t.references :post, null: false, foreign_key: true
      t.string :name, null: false
      t.string :affiliate_url

      t.timestamps
    end

    add_index :items, :name
  end
end
