class PlaylistOfTrack < ApplicationRecord
  belongs_to :playlist
  belongs_to :track

  # 同じ曲が入る可能性があるのでtrack_idにuniquenessはつけない
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }, uniqueness: { scope: :playlist_id }

  scope :identify_by_positions, ->(playlist_id, positions) { where(playlist_id: playlist_id).where(position: positions) }
  scope :identify, ->(playlist_id, position) { find_by(playlist_id: playlist_id, position: position) }
  scope :greater_than_position, ->(playlist_of_track) { where(playlist_id: playlist_of_track.playlist_id).where("position > ?", playlist_of_track.position) }
  scope :all_position_decrement, -> { update_all("position = position - 1")}
  scope :position_asc, -> { order(position: :asc) }
  scope :position_first, -> { find_by(position: 0) }

  def self.all_update(playlist, track_ids)
    PlaylistOfTrack.transaction do
      playlist_of_tracks = track_ids.map.with_index do |id, index|
                            playlist.playlist_of_tracks.new(track_id: id, position: index)
                          end

      PlaylistOfTrack.import!(playlist_of_tracks, validate_uniqueness: true)
    end
  end

  def self.insert_with_position(playlist, track_id_and_positions)
    PlaylistOfTrack.transaction do
      playlist_of_tracks = track_id_and_positions.map do |id, pos|
                             playlist.playlist_of_tracks.new(track_id: id, position: pos)
                           end
      PlaylistOfTrack.import!(playlist_of_tracks, validate_uniqueness: true)
    end
  end
end
