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
    if guest_user?(@user)
      add_playlist_of_track!
    else
      response = request_playlist_add_track(@user, @playlist_id, @track_id)
      if response == 201
        add_playlist_of_track!
      end
    end
  end

  private

  def artist_ids(track)
    track.album.artists.map(&:id)
  end

  def add_playlist_of_track!
    track = request_get_tracks(@track_id)
    Album.find_or_create_by_response!(track.album)
    Artists::ArtistRegistrar.call(artist_ids(track))
    Track.find_or_create_by_response!(track)
    PlaylistOfTrack.create!(playlist_id: @playlist_id, track_id: @track_id)
  end
end