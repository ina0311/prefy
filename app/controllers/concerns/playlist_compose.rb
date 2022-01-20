module PlaylistCompose
  extend ActiveSupport::Concern
  include RequestUrl

  def playlist_track_update(saved_playlist)
    # only_follow_artistがtrueであればフォローアーティストを取得する
    if saved_playlist.only_follow_artist
      artists = current_user.follow_artist_lists.includes(:genres).map do |artist| 
                  artist.attributes.symbolize_keys.slice(:spotify_id, :name).merge({ genre_ids: artist.genres.pluck(:id) })
                end
    end

    # ジャンルが指定されていれば同じジャンルのアーティストのみに絞る
    if saved_playlist.genres.present?
      match_artists = artist_genre_match?(saved_playlist.genres.pluck(:id), artists)
    end

    # 条件に沿って曲を取得する
    tracks = conn_request_search_track(name_and_ids(match_artists), period, saved_playlist_genres)

    # 曲数を絞る
    playlist_of_tracks = tracks.sample(@saved_playlist[:max_number_of_track])

    # 曲からアルバムの情報を取得する
    album_attributes = conn_request_album_info(playlist_of_tracks.pluck(:album_spotify_id).uniq)
    Album.all_insert(album_attributes)
    
    # 曲を保存する
    Track.all_insert(playlist_of_tracks)

    # プレイリストに曲を保存する
    PlaylistOfTrack.all_update(playlist_of_tracks, @saved_playlist.playlist_id)

    conn_request_playlist_update(playlist_of_tracks, @saved_playlist.playlist_id)
  end

  def get_follow_artists_info
    follow_artists = current_user.follow_artist_lists.pluck(:spotify_id)
    conn_request_artist_info(follow_artists)
  end

  def artist_genre_match?(genres, artists)
    match_artists = []
    artists.each { |artist| match_artists << artist if (artist[:genre_ids] & genres).present? }
  end

  def saved_playlist_genres
    @saved_playlist.genres.pluck(:name).map(&:downcase)
  end

  def period
    "#{@saved_playlist.since_year}-#{@saved_playlist.before_year}"
  end

  def name_and_ids(match_artists)
    match_artists.map{ |a| a.slice(:name, :spotify_id) }
  end
end