module PlaylistCompose
  extend ActiveSupport::Concern
  include RequestUrl

  def playlist_track_update(saved_playlist)
    # クエリをsaved_playlistの条件に合わせて作る
    querys = create_query(saved_playlist)

    # 条件に沿って曲を取得する
    tracks = conn_request_search_track(querys)

    # 曲数を絞る
    playlist_of_tracks = limit_track(saved_playlist, tracks)

    # 曲からアルバムの情報を取得する
    album_ids, artist_ids = uniq_album_and_artist_ids(playlist_of_tracks)
    album_attributes = conn_request_album_info(album_ids, artist_ids)
    Album.all_insert(album_attributes)
    
    # 曲を保存する
    Track.all_insert(playlist_of_tracks)

    # プレイリストに曲を保存する
    PlaylistOfTrack.all_update(playlist_of_tracks, saved_playlist.playlist_id)

    conn_request_playlist_update(playlist_of_tracks, saved_playlist.playlist_id)
  end


  def create_query(saved_playlist)
    artists = get_artists_info(saved_playlist) if saved_playlist.only_follow_artist
    genre_names = saved_playlist.genres.only_names if saved_playlist.genres.present?
    period = saved_playlist.since_year.present? ? convert_period(saved_playlist) : saved_playlist.before_year
    type = { artists: artists, genres: genre_names, period: period }

    query_patterns(type)
  end

  def get_artists_info(saved_playlist)
    # ジャンルが指定されていればフォローアーティストを絞り込み検索する
    artists = if saved_playlist.genres.present?
                current_user.follow_artist_lists.includes(:artist_genre_lists).search_genre_names(saved_playlist.genres.only_names)
              else
                current_user.follow_artist_lists.includes(:artist_genre_lists)
              end
    artists.map { |artist| artist.attributes.symbolize_keys.slice(:spotify_id, :name) }
  end


  def convert_period(saved_playlist)
    case
      when saved_playlist.since_year < saved_playlist.before_year
        "#{saved_playlist.since_year}-#{saved_playlist.before_year}"
      when saved_playlist.since_year > saved_playlist.before_year
        "#{saved_playlist.before_year}-#{saved_playlist.since_year}"
      else
        saved_playlist.since_year
    end
  end

  def query_patterns(type)
    querys = []
    string = ''
    string += "year:#{type[:period]}" if type[:period].present?
    string += " genre:#{type[:genres].join(' ')}" if type[:genres].present?
    if type[:artists].present?
      type[:artists].each do |artist|
        str = string.dup
        str += " artist:#{artist[:name]}"
        querys << { query: URI.encode_www_form_component(str), artist_spotify_id: artist[:spotify_id] }
      end
    else
      querys << URI.encode_www_form_component(string)
    end
    querys
  end

  def limit_track(saved_playlist, tracks)
    case
    when saved_playlist.max_number_of_track.present?
      tracks.sample(saved_playlist.max_number_of_track)
    when saved_playlist.max_total_duration_ms.present?
      total_duration_ms = 0
      limited_tracks = []
      tracks.shuffle.each do |track|
        total_duration_ms += track[:duration_ms]
        break if saved_playlist.max_total_duration_ms < total_duration_ms
        limited_tracks << track
      end
      limited_tracks
    else
      track.sample(50)
    end
  end

  def uniq_album_and_artist_ids(tracks)
    ids = tracks.map { |tracks| tracks.slice(:album_spotify_id, :artist_spotify_id) }.uniq
    album_ids = []
    artist_ids = []
    ids.map do |h|
      album_ids << h[:album_spotify_id]
      artist_ids << h[:artist_spotify_id]
    end
    return album_ids, artist_ids
  end
end