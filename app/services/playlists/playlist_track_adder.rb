class Playlists::PlaylistTrackAdder < SpotifyService
  def self.call(user, playlist_of_track)
    new(user: user, playlist_of_track: playlist_of_track).add
  end

  def add
    request_playlist_add_track unless user.guest_user?
    add_playlist_of_track!
  end

  private

  attr_reader :user, :playlist_of_track

  def add_playlist_of_track!
    track = request_get_track
    Album.find_or_create_by_response!(track[:album])
    Track.find_or_create_by_response!(track)
    Artists::ArtistRegistrar.call(user, pick_out_artist_ids(track), track[:album])
    playlist_of_track[:position] = PlaylistOfTrack.where(playlist_id: playlist_of_track.playlist_id).count
    playlist_of_track.save!
    playlist_of_track
  end

  def request_playlist_add_track
    conn_request.post("playlists/#{playlist_of_track.playlist_id}/tracks?uris=spotify:track:#{playlist_of_track.track_id}").status
  end

  def pick_out_artist_ids(track)
    track[:artists].map { |artist| artist[:id] }
  end

  def request_get_track
    conn_request.get("tracks/#{playlist_of_track.track_id}").body
  end
end
