class Playlist < ApplicationRecord
  include RequestUrl

  has_many :saved_playlists, dependent: :destroy
  has_many :playlist_of_tracks, dependent: :destroy

  def self.find_or_create_playlist(playlist_params)
    image = playlist_params[:images][0]
    playlist = Playlist.find_or_create_by(spotify_id: playlist_params[:id]) do |playlist|
                playlist.name = playlist_params[:name]
                playlist.owner = playlist_params[:owner][:id]
                playlist.image = image.nil? ? nil : image[:url]
              end
    playlist
  end
end
