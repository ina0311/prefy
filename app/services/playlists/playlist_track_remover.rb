class Playlists::PlaylistTrackRemover < SpotifyService
  def self.call(user, playlist_of_track)
    new(user: user, playlist_of_track: playlist_of_track).remove
  end

  def remove
    request_remove_playlist_of_track unless user.guest_user?
    playlist_of_track.delete
    PlaylistOfTrack.greater_than_position(playlist_of_track).all_position_decrement
  end

  private

  attr_reader :user, :playlist_of_track

  def request_remove_playlist_of_track
    conn_request.delete("playlists/#{playlist_of_track.playlist_id}/tracks") do |req|
      req.body = { tracks: [{ uri: "spotify:track:#{playlist_of_track.track_id}" }] }.to_json
    end
  end
end
