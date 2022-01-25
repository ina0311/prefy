class SavedPlaylistForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks
  include ActionView::Helpers::DateHelper

  HOUR_TO_MS = 3600000
  MINUTE_TO_MS = 60000

  attr_accessor :user_id, :playlist_id

  attribute :only_follow_artist, :boolean
  attribute :that_generation_preference, :integer
  attribute :since_year, :integer
  attribute :before_year, :integer
  attribute :max_number_of_track, :integer
  attribute :duration_hour, :integer
  attribute :duration_minute, :integer
  attribute :max_total_duration_ms, :integer
  attribute :artist_ids
  attribute :genre_ids
  attribute :track_ids

  validates :only_follow_artist, inclusion: { in: [true, false] }
  validates :max_number_of_track, numericality: { in: 1..50, allow_nil: true }
  validates :duration_hour, numericality: { in: 0..7, allow_nil: true }
  validates :duration_minute, numericality: { in: 0..50, allow_nil: true }
  validates :max_total_duration_ms, numericality: { in: 600_000..25_200_000, allow_nil: true }

  before_validation :set_max_duration_ms

  with_options numericality: { only_integer: true, allow_nil: true }, format: { with: /[0-9]{4}/ } do
    validates :since_year
    validates :before_year
  end

  delegate :persisted?, to: :saved_playlist

  def initialize(attributes = nil, saved_playlist: SavedPlaylist.new)
    @saved_playlist = saved_playlist
    attributes ||= default_attributes
    super(attributes)
  end

  def save(artist_ids, genre_ids, track_ids)
    return if invalid?
    
    ActiveRecord::Base.transaction do
      saved_playlist.update!(
        only_follow_artist: only_follow_artist,
        that_generation_preference: that_generation_preference,
        since_year: since_year,
        before_year: before_year,
        max_number_of_track: max_number_of_track,
        max_total_duration_ms: max_total_duration_ms,
        user_id: user_id,
        playlist_id: playlist_id
      )
    end

    ActiveRecord::Base.transaction do
      unless artist_ids.first.zero?
        default_artist_ids = saved_playlist.saved_playlist_include_artists.ids
        artist_ids.each do |id|
          saved_playlist.saved_playlist_include_artists.find_or_create_by!(artist_id: id)
        end
        
        delete_artist_ids = default_artist_ids - artist_ids
        delete_artist_ids.each { |id| saved_playlist.include_artists.destroy(id) } if delete_artist_ids.present?
      end

      unless genre_ids.first.zero?
        default_genre_ids = saved_playlist.saved_playlist_genres.ids
        genre_ids.each do |id|
          saved_playlist.saved_playlist_genres.find_or_create_by!(genre_id: id)
        end

        delete_genre_ids = default_genre_ids - genre_ids
        delete_genre_ids.each { |id| saved_playlist.genres.destroy(id) } if delete_genre_ids.present?
      end
      
      unless track_ids.first.zero?
        default_track_ids = saved_playlist.saved_playlist_include_tracks.ids
        track_ids.each do |id|
          saved_playlist.saved_playlist_include_tracks.find_or_create_by!(track_id: id)
        end

        delete_track_ids = default_track_ids - track_ids
        delete_track_ids.each { |id| saved_playlist.include_tracks.destroy(id) } if delete_track_ids.present?
      end
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
      only_follow_artist: saved_playlist.only_follow_artist,
      that_generation_preference: saved_playlist.that_generation_preference,
      since_year: saved_playlist.since_year,
      before_year: saved_playlist.before_year,
      max_number_of_track: saved_playlist.max_number_of_track,
      max_total_duration_ms: saved_playlist.max_total_duration_ms,
      user_id: saved_playlist.user_id,
      playlist_id: saved_playlist.playlist_id,
      artist_ids: saved_playlist.saved_playlist_include_artists,
      genre_ids: saved_playlist.saved_playlist_genres,
      track_ids: saved_playlist.saved_playlist_include_tracks
    }
  end

  def set_max_duration_ms
    duration_hour_to_ms = duration_hour * HOUR_TO_MS
    duration_minute_to_ms = duration_minute * MINUTE_TO_MS
    self.max_total_duration_ms = duration_hour_to_ms + duration_minute_to_ms
  end
end