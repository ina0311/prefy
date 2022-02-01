class SavedPlaylistGenre < ApplicationRecord
  belongs_to :saved_playlist
  belongs_to :genre

  validates :saved_playlist_id, uniqueness: { scope: :genre_id }

  def self.upsert(saved_playlist_id, genre_ids)
    SavedPlaylistGenre.transaction do
      objects = genre_ids.map do |id|
                  SavedPlaylistGenre.new(
                    saved_playlist_id: saved_playlist_id,
                    genre_id: id
                  )
                end
      SavedPlaylistGenre.import!(objects)
    end
  end
end
