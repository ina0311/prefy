class SavedPlaylistIncludeArtist < ApplicationRecord
  belongs_to :saved_playlist
  belongs_to :artist
end
