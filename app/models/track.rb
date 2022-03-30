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

  attribute :artist_names
  attribute :image, :string

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

    def find_or_create_by_response!(response)
      Track.find_or_create_by!(
        spotify_id: response.id,
        name: response.name,
        duration_ms: response.duration_ms,
        album_id: response.album.id
      )
    end
  end
end
