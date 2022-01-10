class SavedPlaylist < ApplicationRecord
  include RequestUrl

  belongs_to :user
  belongs_to :playlist
  validates :user_id, uniqueness: { scope: :playlist_id }

  has_many :saved_playlist_genres, dependent: :destroy
  has_many :genres, through: :saved_playlist_genres

  has_many :saved_playlist_include_artists, dependent: :destroy
  has_many :artists, through: :saved_playlist_include_artists

  has_many :saved_playlist_include_tracks, dependent: :destroy
  has_many :tracks, through: :saved_playlist_include_tracks

  enum that_generation_preference: %i(junior_high_school high_school university 20s 30s)

  def self.find_or_create_savedplaylists(response)
    saved_playlists = []
    response.each do |playlist_params|
      playlist = Playlist.find_or_create_playlist(playlist_params) 

      saved_playlist = playlist.saved_playlists.find_or_create_by(playlist_id: playlist[:id])

      saved_playlists << saved_playlist
    end

    saved_playlists
  end
end
