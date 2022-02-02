module PlaylistCompose
  extend ActiveSupport::Concern
  include RequestUrl
  PERCENTAGE = 0.2
  DEFAULT_TOTAL_NUMBER_OF_TRACK = 50

  def playlist_track_update(saved_playlist)
    # クエリをsaved_playlistの条件に合わせて作る
    querys, target_querys = create_query(saved_playlist)

    # 条件に沿って曲を取得する
    tracks = conn_request_search_track(querys)
    if target_querys.present?
      target_tracks = conn_request_search_track(target_querys) 
      playlist_of_tracks = target_track_and_random_select(saved_playlist, target_tracks, tracks)
    else
      playlist_of_tracks = limit_track(saved_playlist, tracks)
    end
    
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
    period = saved_playlist.since_year.present? ? convert_period(saved_playlist) : saved_playlist.before_year
    if saved_playlist.include_artists.present?
      targets = saved_playlist.include_artists.map do |artist| 
        artist.attributes.symbolize_keys.slice(:spotify_id, :name)
      end
    end
    type = { artists: artists, period: period, targets: targets}

    querys, target_querys = query_patterns(type)
  end

  def get_artists_info(saved_playlist)
    # ジャンルが指定されていればフォローアーティストを絞り込み検索する
    artists = if saved_playlist.genres.present?
                current_user.follow_artist_lists.includes(:artist_genre_lists).search_genre_names(saved_playlist.genres.only_names)
              else
                current_user.follow_artist_lists
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
    string = ''
    string += "year:#{type[:period]}" if type[:period].present?
    querys = type[:artists].present? ? artists_querys(type[:artists], string) : URI.encode_www_form_component(string)
    target_querys = artists_querys(type[:targets], string) if type[:targets].present?

    return querys, target_querys
  end

  def artists_querys(artists, string)
    querys = []
    artists.each do |artist|
      str = string.dup
      str += " artist:#{artist[:name]}"
      querys << { query: URI.encode_www_form_component(str), artist_spotify_id: artist[:spotify_id] }
    end
    querys
  end

  def limit_track(saved_playlist, tracks)
    case
    when saved_playlist.max_number_of_track.present?
      tracks.sample(saved_playlist.max_number_of_track)
    when saved_playlist.max_total_duration_ms.present?
      limit_duration_ms(saved_playlist.max_total_duration_ms, tracks)
    else
      tracks.sample(DEFAULT_TOTAL_NUMBER_OF_TRACK)
    end
  end

  def target_track_and_random_select(saved_playlist, target_tracks, tracks)
    playlist_of_tracks = []
    artist_ids = saved_playlist.include_artists.pluck(:spotify_id)
    case
    when saved_playlist.max_number_of_track.present?
      artist_ids.each do |id|
        tg_tracks = target_tracks.select { |track| track[:artist_spotify_id] == id }
        playlist_of_tracks.concat(tg_tracks.sample(saved_playlist.max_number_of_track * PERCENTAGE))
      end
      already = playlist_of_tracks.size
      playlist_of_tracks << tracks.sample(saved_playlist.max_number_of_track - already)
    when saved_playlist.max_total_duration_ms.present? 
      artist_ids.each do |id|
        tg_tracks = target_tracks.select { |track| track[:artist_spotify_id] == id }
        max_duration_ms = saved_playlist.max_total_duration_ms * PERCENTAGE
        playlist_of_tracks << limit_duration_ms(max_duration_ms, tg_tracks)
      end
      limit = saved_playlist.max_total_duration_ms - saved_playlist.max_total_duration_ms * PERCENTAGE * artist_ids.size
      playlist_of_tracks << limit_duration_ms(limit, tracks)
    else
      artist_ids.each do |id|
        tg_tracks = target_tracks.select { |track| track[:artist_spotify_id] == id }
        limit = DEFAULT_TOTAL_NUMBER_OF_TRACK * PERCENTAGE
        playlist_of_tracks.concat(tg_tracks.sample(limit))
      end
      limit = DEFAULT_TOTAL_NUMBER_OF_TRACK - playlist_of_tracks.size
      playlist_of_tracks.concat(tracks.sample(limit))
    end
    playlist_of_tracks.shuffle!
  end

  def uniq_album_and_artist_ids(tracks)
    ids = tracks.map { |track| track.slice(:album_spotify_id, :artist_spotify_id) }.uniq
    album_ids = []
    artist_ids = []
    ids.map do |h|
      album_ids << h[:album_spotify_id]
      artist_ids << h[:artist_spotify_id]
    end
    return album_ids, artist_ids
  end

  def limit_duration_ms(max_total_duration_ms, tracks)
    total_duration_ms = 0
    limited_tracks = []
    tracks.shuffle.each do |track|
      total_duration_ms += track[:duration_ms]
      break if max_total_duration_ms < total_duration_ms
      limited_tracks << track
    end
    limited_tracks
  end
end