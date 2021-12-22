class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :image
      t.string :country, null: false
      t.string :spotify_id, null: false
      t.integer :age
      t.string :encrypted_access_token, null: false
      t.string :encrypted_access_token_iv, null: false
      t.string :encrypted_refresh_token, null: false
      t.string :encrypted_refresh_token_iv, null: false

      t.timestamps
    end
  end
end
