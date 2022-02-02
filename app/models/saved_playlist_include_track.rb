class SavedPlaylistIncludeTrack < ApplicationRecord
  belongs_to :saved_playlist
  belongs_to :track

  validates :saved_playlist_id, uniqueness: { scope: :track_id }
end
