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
    response = request_playlist_add_track(@user, @playlist_id, @track_id)
    if response == 201
      track = request_get_tracks(@track_id)
      album = Album.find_or_create_by_response!(track.album)
      Artists::ArtistRegistrar.call(artist_ids(album))
      Track.find_or_create_by_response!(track)
      PlaylistOfTrack.create!(playlist_id: @playlist_id, track_id: @track_id)
    end
  end

  private

  def artist_ids(album)
    album.artists.map(&:id)
  end
end