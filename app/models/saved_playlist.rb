class SavedPlaylist < ApplicationRecord
  include ConvertQuery
  include TrackRefine

  JUNIOR_HIGH_SCHOOL = 15
  HIGH_SCHOOL = 18
  UNIVERSITY = 22
  TEENS = 20
  TWENTIES = 30
  THIRTIES = 40
  GENERATIONS = [JUNIOR_HIGH_SCHOOL, HIGH_SCHOOL, UNIVERSITY, TEENS, TWENTIES, THIRTIES]
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

  def create_querys
    fillter = self.convert_fillter
    convert_querys(fillter)
  end

  def convert_fillter
    artists = self.get_artists if self.only_follow_artist.present?
    targets = self.include_artists if self.include_artists.present?
    period = self.that_generation_preference? ? convert_generation_to_period : self.period

    { artists: artists, period: period, targets: targets}
  end

  # ジャンルが指定されていればフォローアーティストを絞り込み検索する
  def get_artists
    if self.genres.present?
      self.user.follow_artist_lists.includes(:artist_genre_lists).search_genre_names(self.genres.only_names)
    else
      self.user.follow_artist_lists
    end
  end

  # saved_playlistのカラムによって絞り込み方法を変える
  def refine_tracks(tracks, target_tracks)
    if self.max_total_duration_ms.present?
      self.refine_by_duration_ms(tracks, target_tracks)
    else
      self.refine_by_max_number_of_track(tracks, target_tracks)
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
end
