class SavedPlaylistGenre < ApplicationRecord
  belongs_to :saved_playlist
  belongs_to :genre

  validates :saved_playlist_id, uniqueness: { scope: :genre_id }
end
