class Playlists::PlaylistTrackUpdater < SpotifyService
  def self.call(user, playlist_id, track_ids)
    new(user, playlist_id, track_ids).update
  end

  def initialize(user, playlist_id, track_ids)
    @user = user
    @playlist_id = playlist_id
    @track_ids = track_ids
  end

  def update
    query = @track_ids.join(',spotify:track:')
    response = request_playlist_tracks_update(@user, @playlist_id, query)
    if response == 201
      Tracks::TrackInfoGetter.call(@track_ids)
      PlaylistOfTrack.all_update(@playlist_id, @track_ids)
    end
    
    # TODO statusを確認し、return
  end
end