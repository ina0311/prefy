class SavedPlaylistIncludeTrack < ApplicationRecord
  belongs_to :saved_playlist
  belongs_to :track
end
