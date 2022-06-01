class User < ApplicationRecord
  attr_encrypted :access_token, key: ENV['TOKEN_ENCRYPTION_KEY']
  attr_encrypted :refresh_token, key: ENV['TOKEN_ENCRYPTION_KEY']

  has_many :saved_playlists, dependent: :destroy
  has_many :my_playlists, through: :saved_playlists, source: :playlist
  
  has_many :follow_artists, dependent: :destroy
  has_many :follow_artist_lists, through: :follow_artists, source: :artist

  validates :age, numericality: { in: 1..100, allow_nil: true }
  validates :image, format: { with: /\Ahttps:\/\/i.scdn.co\/image\/[a-z0-9]+\z/, allow_nil: true }

  with_options presence: true do
    validates :name
    validates :spotify_id, uniqueness: true, format: { with: /\w+/ }
    validates :country, format: { with: /[A-Z]{2}/ }
  end

  def self.find_or_create_from_rspotify!(rspotify_user)
    user = User.find_or_initialize_by(spotify_id: rspotify_user.id)
    user.update!(
      name: rspotify_user.display_name,
      image: rspotify_user.images.dig(0, 'url'),
      country: rspotify_user.country,
      access_token: rspotify_user.credentials.token,
      refresh_token: rspotify_user.credentials.refresh_token)
    user
  end

  def own?(playlist)
    spotify_id == playlist.owner
  end

  def guest_user?
    self.spotify_id == 'guest_user'
  end
end
