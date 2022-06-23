class Playlists::PlaylistTracksAllRemover < SpotifyService
  MAX_NUMBER_OF_SENDS = 100

  def self.call(user, playlist)
    new(user: user, playlist: playlist).remove
  end

  def remove
    return if playlist.playlist_of_tracks.blank?

    unless user.guest_user?
      request_bodys = create_request_body
      request_remove_playlist_tracks(request_bodys)
    end
    playlist.playlist_of_tracks.delete_all
  end

  private

  attr_reader :user, :playlist

  def create_request_body
    request_bodys = []
    offset = INITIAL_VALUE
    track_ids = playlist.playlist_of_tracks.pluck(:track_id)
    track_uris = track_ids.map { |id| { uri: "spotify:track:#{id}" } }
    loop do
      request_bodys.push({ tracks: track_uris[offset, MAX_NUMBER_OF_SENDS] })
      break if request_bodys.size == div_max_number_of_sends(track_uris)

      offset += MAX_NUMBER_OF_SENDS
    end

    request_bodys
  end

  def div_max_number_of_sends(track_uris)
    size, surplus = track_uris.size.divmod(MAX_NUMBER_OF_SENDS)
    size += INCREASE unless surplus.zero?
    size
  end

  def request_remove_playlist_tracks(request_bodys)
    request_bodys.each do |request_body|
      conn_request.delete("playlists/#{playlist.spotify_id}/tracks") do |req|
        req.body = request_body.to_json
      end
    end
  end
end
