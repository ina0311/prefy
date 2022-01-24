class User < ApplicationRecord
  attr_encrypted :access_token, key: ENV['TOKEN_ENCRYPTION_KEY']
  attr_encrypted :refresh_token, key: ENV['TOKEN_ENCRYPTION_KEY']

  has_many :saved_playlists, dependent: :destroy
  has_many :my_playlists, through: :saved_playlists, source: :playlist
  
  has_many :follow_artists, dependent: :destroy
  has_many :follow_artist_lists, through: :follow_artists, source: :artist

  with_options presence: true do
    validates :name
    validates :spotify_id, uniqueness: true, format: { with: /\w+/ }
    validates :country, format: { with: /[A-Z]{2}/ }
    validates :image, format: { with: /\Ahttps:\/\/i.scdn.co\/image\/[a-z0-9]+\z/ }
  end

  def own?(playlist)
    spotify_id == playlist.owner
  end
end
