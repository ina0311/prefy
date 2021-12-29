class Playlist < ApplicationRecord
  include RequestUrl

  has_many :saved_playlists, dependent: :destroy
  has_many :playlist_of_tracks, dependent: :destroy

  def self.find_or_create_playlists(response)
    playlists = []
    response.each do |playlist_params|
      image = playlist_params[:images][0]
      
      binding.pry
      
      one_playlist = Playlist.find_or_create_by(spotify_id: playlist_params[:id]) do |playlist|
                      playlist.name = playlist_params[:name]
                      playlist.owner = playlist_params[:owner][:id]
                      playlist.image = image_present?(image)
                    end

      binding.pry

      playlists << one_playlist
    end

    playlists
  end

  def self.image_present?(image)
    
    binding.pry
    
    if image.present?
      image[:url]
    else
      nil
    end
  end
end
