class Artist < ApplicationRecord
  has_many :albums, dependent: :destroy
  has_many :saved_playlist_include_artists, dependent: :destroy
  has_many :follow_artists, dependent: :destroy

  def self.all_update(artist_attributes)
    Artist.transaction do
    artist = artist_attributes.map do |artist|
              Artist.new(
                spotify_id: artist[:id],
                name: artist[:name],
                image: artist[:images][0][:url]
              )
              end

    Artist.import!(artist, on_duplicate_key_update: %i[name image])
    end
  end
end
