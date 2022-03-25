class SavedPlaylist < ApplicationRecord
  PERCENTAGE = 0.2
  DEFAULT = 50
  JUNIOR_HIGH_SCHOOL = 15
  HIGH_SCHOOL = 18
  UNIVERSITY = 22
  TEENS = 20
  TWENTIES = 30
  THIRTIES = 40
  GENERATIONS = [JUNIOR_HIGH_SCHOOL, HIGH_SCHOOL, UNIVERSITY, TEENS, TWENTIES, THIRTIES]
  TEN_MINUTES = 60000

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

  enum that_generation_preference: %i(junior_high_school high_school university teens twenties thirties)

  scope :my_playlists, ->(playlist_ids, user_id) { where(playlist_id: playlist_ids).where(user_id: user_id) }

  def self.add_my_playlists(user, playlist_ids)
    saved_playlists = playlist_ids.map do |id|
                        user.saved_playlists.new(playlist_id: id, created_at: Time.current, updated_at: Time.current)
                      end
    SavedPlaylist.import!(saved_playlists, ignore: true)
  end

  def self.delete_from_my_playlists(user, playlist_ids)
    delete_saved_playlists = user.saved_playlists.includes(:playlist).where(playlist_id: playlist_ids)
    own_playlist_ids = delete_saved_playlists.select { |p| user.own?(p.playlist) }.map{ |p| p.playlist.spotify_id }
    Playlist.delete_owned(own_playlist_ids, user.spotify_id) if own_playlist_ids.present?
    delete_saved_playlists.delete_all
  end

  # saved_playlistの属性をクエリを作るためのフィルターに変換する
  def convert_fillter
    artists = self.get_artists if self.only_follow_artist.present?
    targets = self.include_artists if self.include_artists.present?
    period = self.that_generation_preference? ? convert_generation_to_period : self.period

    return { artists: artists, period: period, targets: targets}
  end

  # ジャンルが指定されていればフォローアーティストを絞り込み検索する
  def get_artists
    if self.genres.present?
      self.user.follow_artist_lists.includes(:artist_genre_lists).search_genre_names(self.genres.only_names)
    else
      self.user.follow_artist_lists
    end
  end

  # that_generationsを西暦に変換する
  def convert_generation_to_period
    this_year = Date.today.year
    age = self.user.age

    case self.that_generation_preference
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

  # フィルターをクエリに変換する
  def convert_querys(fillter)
    string = String.new
    string += "year:#{fillter[:period]}" if fillter[:period].present?
    querys = fillter[:artists].present? ? add_artists(string, fillter[:artists]) : string
    target_querys = add_artists(string, fillter[:targets]) if fillter[:targets].present?

    return querys, target_querys
  end

  # クエリにアーティストを加える
  def add_artists(string, artists)
    artists.map do |artist|
      copy_str = string.dup
      copy_str += " artist:#{artist[:name]}"
      {query: copy_str, artist_spotify_id: artist[:spotify_id]}
    end
  end

  # 曲数で絞り込む
  def refine_by_max_number_of_track(ramdom_tracks, target_tracks)
    total = self.max_number_of_track.present? ? self.max_number_of_track : DEFAULT
    if target_tracks.present?
      refined_target_tracks = target_tracks.map { |tg_tracks| tg_tracks.sample(total * PERCENTAGE) }.flatten     
      remaining = total - refined_target_tracks.size
      refined_ramdom_tracks = ramdom_tracks.sample(remaining)
      return {refined_ramdom_tracks: refined_ramdom_tracks, refined_target_tracks: refined_target_tracks}
    else
      return {refined_ramdom_tracks: ramdom_tracks.sample(total)}
    end
  end

  # 再生時間で絞り込む
  def refine_by_duration_ms(ramdom_tracks, target_tracks)
    playlist_of_tracks = []
    if target_tracks
      limit = self.max_total_duration_ms * PERCENTAGE
      refined_target_tracks = target_tracks.map { |tg_tracks| check_total_duration_and_add_tracks(limit, tg_tracks)}.flatten
      remaining = self.max_total_duration_ms - refined_target_tracks.pluck(:duration_ms).sum
      refine_ramdom_tracks = check_total_duration_and_add_tracks(remaining, ramdom_tracks)
      return {refined_ramdom_tracks: refine_ramdom_tracks, refined_target_tracks: refined_target_tracks}
    else
      return {refined_ramdom_tracks: check_total_duration_and_add_tracks(limit, ramdom_tracks)}
    end
  end

  # 再生時間を判定し、追加
  def check_total_duration_and_add_tracks(limit, tracks)
    playlist_of_tracks = []
    tracks.shuffle!.each do |track|
      playlist_of_tracks << track
      limit -= track[:duration_ms]
      break if limit <= 0
    end

    return playlist_of_tracks
  end

  def number_of_track_less_than_requirements?
    return false unless self.max_number_of_track
    self.max_number_of_track > self.playlist.tracks.size
  end

  def total_duration_more_than_ten_minutes_less_than_requirement?
    return false unless self.max_total_duration_ms
    TEN_MINUTES < (self.max_total_duration_ms - self.playlist.tracks.pluck(:duration_ms).sum)
  end
end
