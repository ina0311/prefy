class Playlist < ApplicationRecord
  include RequestUrl

  has_many :saved_playlists, dependent: :destroy
  has_many :playlist_of_tracks, dependent: :destroy
  has_many :included_tracks, through: :playlist_of_tracks, source: :track

  with_options presence: true do
    validates :name, format: { with: /\A[ぁ-んァ-ン一-龥\w]+/}
    validates :owner, format: { with: /\w+/ }
  end

  scope :my_playlists, ->(ids, user_id) { where(spotify_id: ids).where(owner: user_id) }

  def self.all_update(playlist_attributes)
    Playlist.transaction do
      playlists = playlist_attributes.map do |playlist|
                    Playlist.new(
                      spotify_id: playlist[:spotify_id],
                      name: playlist[:name],
                      owner: playlist[:owner],
                      image: playlist[:image]
                    )
                  end
      Playlist.import!(playlists, on_duplicate_key_update: %i[name image])
    end
  end

  def info_update(info, playlist_id)
    Artist.all_update(info[:artists])
    Album.all_insert(info[:albums])
    Track.all_insert(info[:tracks].uniq)
    PlaylistOfTrack.all_update(info[:tracks], playlist_id)
  end

  def self.create_by_response(response)
    Playlist.create(spotify_id: response[:id],
                    name: response[:name],
                    image: response.dig(:images, 0, :url),
                    owner: response[:owner][:id]
                    )
  end
end
