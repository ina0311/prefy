module TrackRefine
  extend ActiveSupport::Concern
  
  PERCENTAGE = 0.2

  # 曲数で絞り込む
  def refine_by_max_number_of_track(tracks, target_tracks)
    playlist_of_tracks = []
    if target_tracks.present?
      target_tracks.each do |tg_tracks|
        playlist_of_tracks.concat(tg_tracks.sample(self.max_number_of_track * PERCENTAGE))
      end
      remaining = self.max_number_of_track - playlist_of_tracks.size
      playlist_of_tracks.concat(tracks.sample(remaining)).shuffle!
    else
      playlist_of_tracks.concat(tracks.sample(self.max_number_of_track)).shuffle!
    end
  end

  # 再生時間で絞り込む
  def refine_by_duration_ms(tracks, target_tracks)
    playlist_of_tracks = []
    if target_tracks.present?
      limit = self.max_total_duration_ms * PERCENTAGE
      target_tracks.each do |tg_tracks|
        playlist_of_tracks.concat(check_total_duration_and_add_tracks(limit, tg_tracks))
      end
      remaining = self.max_duration_ms - playlist_of_tracks.pluck(:duration_ms).sum
      playlist_of_tracks.concat(check_total_duration_and_add_tracks(remaining, tracks)).shuffle!
    else
      playlist_of_tracks.concat(check_total_duration_and_add_tracks(self.max_total_duration_ms, tracks)).shuffle!
    end
  end

  # 再生時間を判定し、追加
  def check_total_duration_and_add_tracks(limit, tracks)
    playlist_of_tracks = []
    tracks.shuffle!.each do |track|
      limit -= track[:duration_ms]
      break if limit <= 0
      playlist_of_tracks << track
    end
    playlist_of_tracks
  end
end