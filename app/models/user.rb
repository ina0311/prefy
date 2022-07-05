class User < ApplicationRecord
  attr_encrypted :access_token, key: ENV['TOKEN_ENCRYPTION_KEY']
  attr_encrypted :refresh_token, key: ENV['TOKEN_ENCRYPTION_KEY']

  has_many :saved_playlists, dependent: :destroy
  has_many :my_playlists, through: :saved_playlists, source: :playlist
  has_many :follow_artists, dependent: :destroy
  has_many :follow_artist_lists, through: :follow_artists, source: :artist

  validates :age, numericality: { in: 1..100, allow_nil: true }
  validates :image, format: { with: %r(\Ahttps://i.scdn.co/image/[a-z0-9]+\z), allow_nil: true }

  with_options presence: true do
    validates :name
    validates :spotify_id, uniqueness: true, format: { with: /\w+/ }
    validates :country, format: { with: /[A-Z]{2}/ }
  end

  def self.find_or_create_from_omniauth!(auth)
    user = User.find_or_initialize_by(spotify_id: auth[:uid])
    user.update!(
      name: auth[:info][:name],
      image: auth[:info][:image],
      country: auth[:info][:country_code],
      access_token: auth[:credentials][:token],
      refresh_token: auth[:credentials][:token]
    )
    user
  end

  def own?(playlist)
    spotify_id == playlist.owner
  end

  def guest_user?
    spotify_id == 'guest_user'
  end
end
