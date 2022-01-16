class Track < ApplicationRecord
  belongs_to :album

  has_many :playlist_of_tracks, dependent: :destroy
  has_many :track_genres, dependent: :destroy
  has_many :saved_playlist_include_tracks, dependent: :destroy
  has_many :saved_playlists, through: :saved_playlist_include_tracks

  def self.all_insert(track_attributes)
    Track.transaction do
      tracks = track_attributes.map do |track|
        Track.new(
          spotify_id: track[:spotify_id],
          name: track[:name],
          duration_ms: track[:duration_ms],
          album_id: search_album(track[:album_id])
        )
      end
    end
  end

  def search_album(id)
    Album.find_by(spotify_id: id).id
  end
end
