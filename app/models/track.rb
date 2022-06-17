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

  attribute :album_name, :string
  attribute :artist_ids
  attribute :artist_names
  attribute :image, :string

  class << self
    
    def all_import!(response)
      Track.transaction do
        tracks = response.map do |res| 
          Track.new(
            spotify_id: res[:id],
            name: res[:name],
            duration_ms: res[:duration_ms],
            position: res[:track_number],
            album_id: res[:album][:id]
          )
        end
        Track.import!(tracks, ignore: true)
      end
    end

    def find_or_initialize_by_response!(response)
      Track.find_or_initialize_by(spotify_id: response[:id]) do |track|
        track.name = response[:name]
        track.duration_ms = response[:duration_ms]
        track.position = response[:traci_number]
        track.album_id = response[:album][:id]
      end
    end
  end
end
