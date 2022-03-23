class Playlists::PlaylistTracksRemover < SpotifyService
  MAX_NUMBER_OF_SENDS = 100
  INITIAL_VALUE = 0
  INCREASE = 1

  def self.call(user, playlist, track_ids)
    new(user, playlist, track_ids).remove
  end

  def initialize(user, playlist, track_ids)
    @user = user
    @playlist = playlist
    @track_ids = track_ids
  end

  def remove
    unless user.guest_user?
      request_bodys = track_ids.instance_of?(Array) ? create_request_body : {tracks: [{uri: "spotify:track:#{track_ids}"}]}
      request_remove_playlist_tracks(request_bodys)
    end
    playlist.playlist_of_tracks.delete_all
  end

  private

  attr_reader :user, :playlist, :track_ids

  def create_request_body
    request_bodys = []
    offset = INITIAL_VALUE
    track_uris = track_ids.map { |id| {uri: "spotify:track:#{id}"} }
    while true
      request_bodys << {tracks: track_uris[offset, MAX_NUMBER_OF_SENDS]}
      break if request_bodys.size == div_max_number_of_sends(track_uris)
      offset += MAX_NUMBER_OF_SENDS
    end
    return request_bodys
  end

  def div_max_number_of_sends(track_uris)
    size, surplus = track_uris.size.divmod(MAX_NUMBER_OF_SENDS)
    return surplus.zero? ? size : size += INCREASE
  end

  def request_remove_playlist_tracks(request_bodys)
    if track_ids.instance_of?(Array)
      request_bodys.each do |request_body|
        conn_request.delete("playlists/#{playlist.spotify_id}/tracks") do |req|
          req.body = request_body.to_json
        end
      end
    else
      conn_request.delete("playlists/#{playlist.spotify_id}/tracks") do |req|
        req.body = request_bodys.to_json
      end
    end
  end
end