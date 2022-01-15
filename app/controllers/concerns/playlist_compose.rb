module PlaylistCompose
  extend ActiveSupport::Concern
  include RequestUrl

  def playlist_track_update(saved_playlist)
    query = query_create
    artist_info = get_follow_artists_info if @saved_playlist.only_follow_artist

    match_artists = artist_genre_match?(saved_playlist_genres, artist_info)

    tracks = conn_request_search_track(match_artists.pluck(:name), period, saved_playlist_genres)
    playlist_of_tracks = tracks.sample(@saved_playlist[:max_number_of_track])
    
    binding.pry
  end

  def query_create
    query = []
    genre_names = @saved_playlist.genres.pluck(:name)
    artist_ids = Artist.where(id: @saved_playlist.artists.ids)
    track_ids = Track.where(spotify_id: @saved_playlist.tracks.ids)
  end

  def get_follow_artists_info
    follow_artists = current_user.follow_artist_lists.pluck(:spotify_id)
    conn_request_artist_info(follow_artists)
  end

  def artist_genre_match?(genres, artist_info)
    match_artists = []
    genres.each do |genre|
      artist_info.each do |artist|
        match_artists << artist if artist[:genres].map { |g| /#{genre}/.match?(g) }.any?
      end
    end
    match_artists
  end

  def saved_playlist_genres
    @saved_playlist.genres.pluck(:name).map(&:downcase)
  end

  def period
    "#{@saved_playlist.since_year}-#{@saved_playlist.before_year}"
  end
end