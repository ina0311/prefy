class Playlist < ApplicationRecord
  include RequestUrl

  def self.find_or_create_playlists(response)
    playlists = []
    response.each do |playlist_params|
      image = playlist_params[:images][0],
      my_playlist = Playlist.find_or_create_by(
        spotify_id: playlist_params[:id],
        name: playlist_params[:name],
        owner: playlist_params[:owner][:id],
        image: image_nil?(image))

      playlists << my_playlist
    end

    playlists
  end

  def self.image_nil?(image)
    if image.present?
      image[:url]
    else
      nil
    end
  end
end
