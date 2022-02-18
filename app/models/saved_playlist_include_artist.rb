class SavedPlaylistIncludeArtist < ApplicationRecord
  belongs_to :saved_playlist
  belongs_to :artist

  validates :saved_playlist_id, uniqueness: { scope: :artist_id }

  scope :specific, ->(saved_playlist_id, artist_ids) { where(saved_playlist_id: saved_playlist_id).where(artist_id: artist_ids) }

  def self.upsert(artist_ids, saved_playlist_id)
    SavedPlaylistIncludeArtist.transaction do
      objects = artist_ids.map do |id|
                SavedPlaylistIncludeArtist.new(
                  saved_playlist_id: saved_playlist_id,
                  artist_id: id
                )
               end

      SavedPlaylistIncludeArtist.import!(objects)
    end
  end
end
