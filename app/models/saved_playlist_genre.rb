class SavedPlaylistGenre < ApplicationRecord
  belongs_to :saved_playlist
  belongs_to :genre
end
