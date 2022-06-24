class SavedPlaylist < ApplicationRecord
  PERCENTAGE = 0.2
  DEFAULT = 50
  JUNIOR_HIGH_SCHOOL = 15
  HIGH_SCHOOL = 18
  UNIVERSITY = 22
  TEENS = 20
  TWENTIES = 30
  THIRTIES = 40
  GENERATIONS = [JUNIOR_HIGH_SCHOOL, HIGH_SCHOOL, UNIVERSITY, TEENS, TWENTIES, THIRTIES].freeze
  TEN_MINUTES = 60_000
  HOUR_TO_MS = 3_600_000
  MINUTE_TO_MS = 60_000

  belongs_to :user
  belongs_to :playlist

  validates :user_id, uniqueness: { scope: :playlist_id }
  # その他のバリデーションはFormに記載

  has_many :saved_playlist_genres, dependent: :destroy
  has_many :genres, through: :saved_playlist_genres

  has_many :saved_playlist_include_artists, dependent: :destroy
  has_many :include_artists, through: :saved_playlist_include_artists, source: :artist

  has_many :saved_playlist_include_tracks, dependent: :destroy
  has_many :include_tracks, through: :saved_playlist_include_tracks

  enum that_generation_preference: { junior_high_school: 0, high_school: 1, university: 2, teens: 3, twenties: 4, thirties: 5 }

  def self.add_my_playlists(user, playlist_ids)
    saved_playlists = playlist_ids.map do |id|
      user.saved_playlists.new(playlist_id: id, created_at: Time.current, updated_at: Time.current)
    end
    SavedPlaylist.import!(saved_playlists, ignore: true)
  end

  def self.delete_from_my_playlists(user, playlist_ids)
    destroy_own_playlists = user.my_playlists.own_playlists(playlist_ids, user.spotify_id)
    destroy_own_playlists&.destroy_all
    delete_saved_playlists = user.saved_playlists.where(playlist_id: playlist_ids)
    delete_saved_playlists.delete_all
  end

  def convert_year
    if that_generation_preference.present?
      " year:#{convert_generation_to_period}"
    elsif period.present?
      " year:#{period}"
    else
      ''
    end
  end

  # ジャンルが指定されていればフォローアーティストを絞り込み検索する
  def call_artist_ids
    if genres.present?
      user.follow_artist_lists.includes(:genres).search_genre_names(genres.only_names).ids
    else
      user.follow_artist_lists.ids
    end
  end

  # that_generationsを西暦に変換する
  def convert_generation_to_period
    this_year = Time.zone.today.year
    age = user.age

    case that_generation_preference
    when 'junior_high_school'
      since_year = this_year - (age - JUNIOR_HIGH_SCHOOL)
      "#{since_year - 3}-#{since_year}"
    when 'high_school'
      since_year = this_year - (age - HIGH_SCHOOL)
      "#{since_year - 3}-#{since_year}"
    when 'university'
      since_year = this_year - (age - UNIVERSITY)
      "#{since_year - 4}-#{since_year}"
    when 'teens'
      since_year = this_year - (age - TEENS)
      "#{since_year - 10}-#{since_year}"
    when 'twenties'
      since_year = this_year - (age - TWENTIES)
      "#{since_year - 10}-#{since_year}"
    when 'thirties'
      since_year = this_year - (age - THIRTIES)
      "#{since_year - 10}-#{since_year}"
    end
  end

  def refine_tracks(ramdom_tracks, target_tracks)
    if max_total_duration_ms
      refine_by_duration_ms(ramdom_tracks, target_tracks)
    else
      refine_by_max_number_of_track(ramdom_tracks, target_tracks)
    end
  end

  # 曲数で絞り込む
  def refine_by_max_number_of_track(ramdom_tracks, target_tracks)
    total = max_number_of_track.presence || DEFAULT
    if target_tracks.present?
      refined_target_tracks = target_tracks.map { |tg_tracks| tg_tracks.sample(total * PERCENTAGE) }
      remaining = total - refined_target_tracks.flatten.size
      refined_ramdom_tracks = ramdom_tracks.sample(remaining)
      { ramdom_tracks: refined_ramdom_tracks, target_tracks: refined_target_tracks }
    else
      { ramdom_tracks: ramdom_tracks.sample(total) }
    end
  end

  # 再生時間で絞り込む
  def refine_by_duration_ms(ramdom_tracks, target_tracks)
    if target_tracks
      limit = max_total_duration_ms * PERCENTAGE
      refined_target_tracks = target_tracks.map { |tg_tracks| refine_total_duration_and_add_tracks(limit, tg_tracks) }.flatten
      remaining = max_total_duration_ms - refined_target_tracks.pluck(:duration_ms).sum
      refine_ramdom_tracks = refine_total_duration_and_add_tracks(remaining, ramdom_tracks)
      { ramdom_tracks: refine_ramdom_tracks, target_tracks: refined_target_tracks }
    else
      { ramdom_tracks: refine_total_duration_and_add_tracks(max_total_duration_ms, ramdom_tracks) }
    end
  end

  # 再生時間を判定し、追加
  def refine_total_duration_and_add_tracks(limit, tracks)
    refine_tracks = []
    tracks.shuffle.each do |track|
      refine_tracks.push(track)
      limit -= track[:duration_ms]
      break if limit <= 0
    end

    refine_tracks
  end

  def not_has_track_by_require_artists(tracks)
    return include_artists.pluck(:name) if tracks.nil?

    track_artist_ids = tracks.flatten.map { |track| track[:artist_ids] }.uniq.flatten
    not_get_artists = include_artists.map do |artist|
      next if track_artist_ids.include?(artist[:spotify_id])

      artist.name
    end
    not_get_artists.compact
  end

  def check_saved_playlist_requirements
    if max_number_of_track
      number_of_track_less_than_requirements?
    else
      total_duration_more_than_ten_minutes_less_than_requirement?
    end
  end

  def number_of_track_less_than_requirements?
    return if max_number_of_track == playlist.tracks.size

    ErrorsHandler::NotEnoughTrackInPlaylist
  end

  def total_duration_more_than_ten_minutes_less_than_requirement?
    return if TEN_MINUTES > (max_total_duration_ms - playlist.tracks.pluck(:duration_ms).sum)

    ErrorsHandler::NotEnoughPlaybackTimeForPlaylist
  end
end
