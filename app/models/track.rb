class Track < ApplicationRecord
  belongs_to :album
  delegate :artist, to: :album

  has_many :playlist_of_tracks, dependent: :destroy
  has_many :saved_playlist_include_tracks, dependent: :destroy
  has_many :saved_playlists, through: :saved_playlist_include_tracks

  with_options presence: true do 
    validates :name
    validates :duration_ms, numericality: { only_integer: true }
  end

  class << self
    
    def all_import!(response)
      Track.transaction do
        tracks = response.map do |res|
          Track.new(
            spotify_id: res.id,
            name: res.name,
            duration_ms: res.duration_ms,
            album_id: res.album.id
          )
        end
  
        Track.import!(tracks, ignore: true)
      end
    end
  
    def response_convert_tracks(response)
      tracks = []
      response.each do |res|
        next if res.blank?
        artist_tracks = []
        res.each do |r|
          next if artist_tracks.map { |t| t.name == r.name }.any?
          track = Track.new(
                            spotify_id: r.id, 
                            name: r.name, 
                            duration_ms: r.duration_ms, 
                            album_id: r.album.id
                            )
  
          artist_tracks << track
        end
        tracks << artist_tracks
      end
      tracks
    end
  end
  
end
