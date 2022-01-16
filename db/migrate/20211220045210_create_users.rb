class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users, id: false do |t|
      t.string :spotify_id, null: false, primary_key: true
      t.string :name, null: false
      t.string :image
      t.string :country, null: false
      t.integer :age
      t.text :encrypted_access_token
      t.text :encrypted_access_token_iv
      t.text :encrypted_refresh_token
      t.text :encrypted_refresh_token_iv

      t.timestamps
    end
  end
end
