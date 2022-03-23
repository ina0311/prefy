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
    if user.guest_user?
      add_playlist_of_track!
    else
      response = request_playlist_add_track
      if response == 201
        add_playlist_of_track!
      end
    end
  end

  private

  attr_reader :user, :playlist_id, :track_id

  def artist_ids(track)
    track.album.artists.map(&:id)
  end

  def add_playlist_of_track!
    track = request_get_track
    album = Album.find_or_create_by_response!(track.album)
    Track.find_or_create_by_response!(track)
    Artists::ArtistRegistrar.call(track.artists.map(&:id), album)
    PlaylistOfTrack.create!(playlist_id: playlist_id, track_id: track_id, position: 0)
  end

  def request_playlist_add_track
    conn_request.post("playlists/#{playlist_id}/tracks?uris=spotify:track:#{track_id}").status
  end

  def request_get_track
    RSpotify::Track.find(track_id)
  end
end