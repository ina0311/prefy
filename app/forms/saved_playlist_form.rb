class SavedPlaylistForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks
  include Draper::Decoratable

  HOUR_TO_MS = 3600000
  MINUTE_TO_MS = 60000

  attribute :playlist_name, :string
  attribute :only_follow_artist, :boolean
  attribute :that_generation_preference, :integer
  attribute :period, :string
  attribute :since_year, :integer
  attribute :before_year, :integer
  attribute :max_number_of_track, :integer
  attribute :duration_hour, :integer
  attribute :duration_minute, :integer
  attribute :max_total_duration_ms, :integer
  attribute :artist_ids
  attribute :genre_ids
  attribute :user_id, :string
  attribute :playlist_id, :string

  validates :only_follow_artist, inclusion: { in: [true, false] }
  validates :max_number_of_track, numericality: { in: 1..50, allow_nil: true }
  validates :period, format: { with: /([0-9]{4})+(-[0-9]{4})*/ }, allow_blank: true
  validates :duration_hour, numericality: { in: 1..7, allow_nil: true }
  validates :duration_minute, numericality: { in: 10..50, allow_nil: true }
  validates :max_total_duration_ms, numericality: { in: 600_000..25_200_000, allow_nil: true }
  validate :only_either_generation_or_period, unless: -> { that_generation_preference.nil? && period.nil? }
  validate :only_either_numver_of_track_or_duration_ms, unless: -> { max_number_of_track.nil? && max_total_duration_ms.nil?}

  with_options numericality: { only_integer: true }, allow_blank: true, format: { with: /[0-9]{4}/ } do
    validates :since_year
    validates :before_year
  end

  with_options length: { maximum: 3 } do
    validates :artist_ids
    validates :genre_ids
  end

  with_options presence: true do
    validates :user_id
    validates :playlist_id
  end

  before_validation :set_max_duration_ms, :set_period

  delegate :persisted?, to: :saved_playlist

  def initialize(attributes = nil, saved_playlist: SavedPlaylist.new)
    @saved_playlist = saved_playlist
    attributes ||= default_attributes
    super(attributes)
  end

  def save(artist_ids, genre_ids)
    return if invalid?

    saved_playlist = SavedPlaylist.find_or_initialize_by(user_id: user_id, playlist_id: playlist_id)
    ActiveRecord::Base.transaction do
      saved_playlist.update!(
        only_follow_artist: only_follow_artist,
        that_generation_preference: that_generation_preference,
        period: period,
        max_number_of_track: max_number_of_track,
        max_total_duration_ms: max_total_duration_ms
      )
    end

    ActiveRecord::Base.transaction do
      default_artist_ids = saved_playlist.saved_playlist_include_artists.pluck(:artist_id)
      delete_artist_ids = artist_ids.present? ? default_artist_ids - artist_ids : default_artist_ids
      SavedPlaylistIncludeArtist.all_import!(artist_ids, saved_playlist.id) if artist_ids.present?
      SavedPlaylistIncludeArtist.specific(saved_playlist.id, delete_artist_ids).delete_all if delete_artist_ids.present?

      default_genre_ids = saved_playlist.saved_playlist_genres.pluck(:genre_id)
      delete_genre_ids = genre_ids.present? ? default_genre_ids - genre_ids : default_genre_ids
      SavedPlaylistGenre.all_import!(saved_playlist.id, genre_ids) if  genre_ids.present?
      SavedPlaylistGenre.specific(saved_playlist.id, delete_genre_ids).delete_all if delete_genre_ids.present?
    end
    saved_playlist.persisted?
  end

  def to_model
    saved_playlist
  end

  def is_only_error_to_playlist_id?
    self.valid?
    return self.errors.errors.map { |e| e.attribute == :playlist_id }.all?
  end

  private

  attr_reader :saved_playlist

  def default_attributes
    {
      playlist_name: saved_playlist.playlist&.name,
      only_follow_artist: saved_playlist.only_follow_artist,
      that_generation_preference: saved_playlist.that_generation_preference,
      period: saved_playlist.period,
      max_number_of_track: saved_playlist.max_number_of_track,
      max_total_duration_ms: saved_playlist.max_total_duration_ms,
      user_id: saved_playlist.user_id,
      playlist_id: saved_playlist.playlist_id,
      artist_ids: saved_playlist.saved_playlist_include_artists.pluck(:artist_id),
      genre_ids: saved_playlist.saved_playlist_genres.pluck(:genre_id)
    }
  end

  def set_max_duration_ms
    duration_hour_to_ms = duration_hour * HOUR_TO_MS
    duration_minute_to_ms = duration_minute * MINUTE_TO_MS
    total = duration_hour_to_ms + duration_minute_to_ms
    self.max_total_duration_ms = total > 0 ? total : nil
  end

  def set_period
    self.period = case 
                  when since_year.blank? && before_year.blank?
                    nil
                  when since_year.blank? && before_year.present?
                    "#{before_year}"
                  when since_year.present? && before_year.blank?
                    "#{since_year}"
                  when since_year < before_year
                    "#{since_year}-#{before_year}"
                  when since_year > before_year
                    "#{before_year}-#{since_year}"
                  end
  end

  def only_either_generation_or_period
    return if that_generation_preference.present? ^ period.present?
    
    errors.add("西暦と年代はどちらかのみを選択してください")
  end

  def only_either_numver_of_track_or_duration_ms
    return if max_number_of_track.present? ^ max_total_duration_ms.present?
    
    errors.add("曲数と再生時間はどちらかのみを選択してください")
  end
end