class SavedPlaylistIncludeArtist < ApplicationRecord
  belongs_to :saved_playlist
  belongs_to :artist

  validates :saved_playlist_id, uniqueness: { scope: :artist_id }
end
