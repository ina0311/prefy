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
        tracks = response.map { |res| Track.find_or_create_by_response!(res) }
        Track.import!(tracks, ignore: true)
      end
    end

    def find_or_create_by_response!(response)
      Track.find_or_create_by!(spotify_id: response[:id]) do |track|
        track.name = response[:name]
        track.duration_ms = response[:duration_ms]
        track.album_id = response[:album][:id]
      end
    end
  end
end
