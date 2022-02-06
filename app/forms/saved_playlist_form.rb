class SavedPlaylistForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks
  include ActionView::Helpers::DateHelper

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

  with_options numericality: { only_integer: true }, allow_blank: true, format: { with: /[0-9]{4}/ } do
    validates :since_year
    validates :before_year
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
    
    ActiveRecord::Base.transaction do
      saved_playlist.update!(
        only_follow_artist: only_follow_artist,
        that_generation_preference: that_generation_preference,
        period: period,
        max_number_of_track: max_number_of_track,
        max_total_duration_ms: max_total_duration_ms,
        user_id: user_id,
        playlist_id: playlist_id
      )
    end

    ActiveRecord::Base.transaction do
      default_artist_ids = saved_playlist.saved_playlist_include_artists.pluck(:artist_id)
      SavedPlaylistIncludeArtist.upsert(artist_ids, saved_playlist.id) if artist_ids.all? { |e| e.is_a?(String) && e.present? } 
      delete_artist_ids = default_artist_ids - artist_ids
      SavedPlaylistIncludeArtist.where(artist_id: delete_artist_ids).delete_all if delete_artist_ids.present?

      default_genre_ids = saved_playlist.saved_playlist_genres.pluck(:genre_id)
      SavedPlaylistGenre.upsert(saved_playlist.id, genre_ids) unless genre_ids.first.zero?
      delete_genre_ids = default_genre_ids - genre_ids
      SavedPlaylistGenre.where(genre_id: delete_genre_ids).delete_all if delete_genre_ids.present?
    end
    saved_playlist.persisted?
  end

  def to_model
    saved_playlist
  end

  def years
    select_year(nil, start_year: Date.today.year, end_year: 1900).scan(/\d{4}/).uniq.map{ |s| s.to_i }
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
      artist_ids: saved_playlist.saved_playlist_include_artists,
      genre_ids: saved_playlist.saved_playlist_genres
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
                  when since_year < before_year
                    "#{since_year}-#{before_year}"
                  when since_year > before_year
                    "#{before_year}-#{since_year}"
                  when since_year.present? && before_year.blank?
                    "#{since_year}"
                  when since_year.blank? && before_year.present?
                    "#{before_year}"
                  end
  end
end