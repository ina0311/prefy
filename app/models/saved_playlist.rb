class SavedPlaylist < ApplicationRecord
  include RequestUrl

  belongs_to :user
  belongs_to :playlist

  validates :user_id, uniqueness: { scope: :playlist_id }

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
