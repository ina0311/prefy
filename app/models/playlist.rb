class Playlist < ApplicationRecord
  include RequestUrl

  has_one :saved_playlist, dependent: :destroy
  has_many :playlist_of_tracks, dependent: :destroy
  has_many :included_tracks, through: :playlist_of_tracks, source: :track

  with_options presence: true do
    validates :name, format: { with: /\A[ぁ-んァ-ン一-龥\w]+/}
    validates :owner, format: { with: /\w+/ }
  end

  scope :my_playlists, ->(ids, user_id) { where(spotify_id: ids).where(owner: user_id) }

  def self.all_update(response)
    Playlist.transaction do
      playlists = response.map do |res|
                    Playlist.new(
                      spotify_id: res[:id],
                      name: res[:name],
                      owner: res[:owner][:id],
                      image: res.dig(:images, 0, :url)
                    )
                  end
      Playlist.import!(playlists, on_duplicate_key_update: %i[name image])
    end
  end

  def self.create_by_response(response)
    Playlist.create(
      spotify_id: response[:id],
      name: response[:name],
      image: response.dig(:images, 0, :url),
      owner: response[:owner][:id]
    )
  end
end
