class Playlists::PlaylistTrackAdder < SpotifyService
  def self.call(user, playlist_of_track)
    new(user, playlist_of_track).add
  end

  def initialize(user, playlist_of_track)
    @user = user
    @playlist_of_track = playlist_of_track
  end

  def add
    request_playlist_add_track unless user.guest_user?
    return add_playlist_of_track!
  end

  private

  attr_reader :user, :playlist_of_track

  def add_playlist_of_track!
    track = request_get_track
    Album.find_or_create_by_response!(track.album)
    Track.find_or_create_by_response!(track)
    Artists::ArtistRegistrar.call(track.artists.map(&:id), track.album)
    playlist_of_track[:position] = PlaylistOfTrack.where(playlist_id: playlist_of_track.playlist_id).count
    playlist_of_track.save!
    return playlist_of_track
  end

  def request_playlist_add_track
    conn_request.post("playlists/#{playlist_of_track.playlist_id}/tracks?uris=spotify:track:#{playlist_of_track.track_id}").status
  end

  def artist_ids(track)
    track.album.artists.map(&:id)
  end

  def request_get_track
    RSpotify::Track.find(playlist_of_track.track_id)
  end
end