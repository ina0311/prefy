class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :image
      t.string :country, null: false
      t.string :spotify_id, null: false
      t.integer :age
      t.text :encrypted_access_token
      t.text :encrypted_access_token_iv
      t.text :encrypted_refresh_token
      t.text :encrypted_refresh_token_iv

      t.timestamps
    end
    add_index :users, [:spotify_id], unique: true
  end
end
