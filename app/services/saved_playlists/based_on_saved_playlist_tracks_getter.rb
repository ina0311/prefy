class SavedPlaylists::BasedOnSavedPlaylistTracksGetter < SpotifyService
  # saved_playlistの情報からクエリを作成、曲を取得、絞り込み
  def self.call(saved_playlist, user)
    new(saved_playlist, user).get
  end

  def initialize(saved_playlist, user)
    @saved_playlist = saved_playlist
    @user = user
  end
  
  def get
    year = saved_playlist.convert_year
    if saved_playlist.only_follow_artist
      artist_ids = saved_playlist.get_artist_ids
      ramdom_tracks = search_tracks(artist_ids, year).flatten
    end

    if saved_playlist.include_artists
      target_ids = saved_playlist.include_artists.ids 
      target_tracks = search_tracks(target_ids, year)
    end
    
    return false if ramdom_tracks.blank? && target_tracks.blank?

    refined_ramdom_and_target_tracks = saved_playlist.refine_tracks(ramdom_tracks, target_tracks)
    return refined_ramdom_and_target_tracks
  end

  private

  attr_reader :saved_playlist, :user

  def search_tracks(ids, year)
    request_params = create_request_params(ids, year)
    tracks = request_search_tracks(request_params)
    return tracks
  end

  def create_request_params(ids, year)
    offset = INITIAL_VALUE
    response = Array.new 
    while true
      response.concat(RSpotify::Artist.find(ids[offset, 50]))
      break if ids.size == response.size
      offset += PLUS_FIFTY
    end
    request_params = response.map do |res|
                      string = "artist:#{res.name}"
                      string += year if year
                      {id: res.id, params: URI.encode_www_form_component(string)}
                     end
    
    return request_params
  end

  def request_search_tracks(request_params)
    tracks = request_params.map do |req|
               response = conn_request.get("search?q=#{req[:params]}&type=track&limit=50").body[:tracks][:items]
               next if response.blank?
               artist_tracks = response.map do |res|
                                 next nil if should_remove_response?(res, req[:id])
                                 track = {
                                  spotify_id: res[:id],
                                  name: res[:name],
                                  duration_ms: res[:duration_ms],
                                  artist_id: res[:artists].pluck(:id)
                                }
                               end
                artist_tracks.compact.uniq { |track| track[:name] }
             end
    tracks.reject!(&:blank?)
    return tracks
  end

  # アルバムのタイプがコンピレーション、または違うアーティストの曲は弾く
  def should_remove_response?(response, request_artist_id)
    case 
    when response[:album][:album_type] == 'compilation'
      return true
    when response[:artists].map { |artist| artist[:id] != request_artist_id }.all?
      return true
    else
      return false
    end
  end
end