class Artist < ApplicationRecord
  has_many :albums, dependent: :destroy
  has_many :saved_playlist_include_artists, dependent: :destroy
  has_many :follow_artists, dependent: :destroy

  def self.find_or_create_artist(artist_params)
    Artist.find_or_create_by!(spotify_id: artist_params[:id]) do |artist|
      artist.name = artist_params[:name]
      artist.image = artist_params[:images][0][:url]
    end
  end
end
