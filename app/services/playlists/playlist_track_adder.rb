class Playlists::PlaylistTrackAdder < SpotifyService
  def self.call(user, playlist_id, track_id)
    new(user, playlist_id, track_id).add
  end

  def initialize(user, playlist_id, track_id)
    @user = user
    @playlist_id = playlist_id
    @track_id = track_id
  end

  def add
    request_playlist_add_track unless user.guest_user?
    @playlist_of_track = add_playlist_of_track!
    return @playlist_of_track
  end

  private

  attr_reader :user, :playlist_id, :track_id

  def artist_ids(track)
    track.album.artists.map(&:id)
  end

  def add_playlist_of_track!
    track = request_get_track
    Album.find_or_create_by_response!(track.album)
    Track.find_or_create_by_response!(track)
    Artists::ArtistRegistrar.call(track.artists.map(&:id), track.album)
    last = PlaylistOfTrack.where(playlist_id: playlist_id).count
    PlaylistOfTrack.create!(playlist_id: playlist_id, track_id: track_id, position: last)
  end

  def request_playlist_add_track
    conn_request.post("playlists/#{playlist_id}/tracks?uris=spotify:track:#{track_id}").status
  end

  def request_get_track
    RSpotify::Track.find(track_id)
  end
end