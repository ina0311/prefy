class Track < ApplicationRecord
  belongs_to :album
  delegate :artist, to: :album

  has_many :playlist_of_tracks, dependent: :destroy
  has_many :saved_playlist_include_tracks, dependent: :destroy
  has_many :saved_playlists, through: :saved_playlist_include_tracks

  def self.all_insert(track_attributes)
    Track.transaction do
      tracks = track_attributes.map do |track|
        Track.new(
          spotify_id: track[:spotify_id],
          name: track[:name],
          duration_ms: track[:duration_ms],
          album_id: track[:album_spotify_id]
        )
      end

      Track.import!(tracks, ignore: true)
    end
  end
end
