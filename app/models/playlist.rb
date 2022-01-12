class Playlist < ApplicationRecord
  include RequestUrl

  has_many :saved_playlists, dependent: :destroy
  has_many :playlist_of_tracks, dependent: :destroy

  def self.all_update(playlist_attributes)
    Playlist.transaction do
      playlists = playlist_attributes.map do |playlist|
                    Playlist.new(
                      spotify_id: playlist[:spotify_id],
                      name: playlist[:name],
                      owner: playlist[:owner],
                      image: playlist[:image]
                    )
                  end
      Playlist.import!(playlists, on_duplicate_key_update: %i[name image])
    end
  end
end
