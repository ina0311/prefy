class Playlists::TrackUpdater < SpotifyService
  def self.call(user, playlist_id, tracks)
    new(user, playlist_id, tracks).update
  end

  def initialize(user, playlist_id, tracks)
    @user = user
    @playlist_id = playlist_id
    @tracks = tracks
  end

  def update
    query = @tracks.pluck(:spotify_id).join(',spotify:track:')
    response = request_playlist_tracks_update(@user, @playlist_id, query)
    if response == 201
      Track.import!(@tracks, ignore: true)
      PlaylistOfTrack.all_update(@playlist_id, @tracks.map(&:spotify_id))
    end
    
    # TODO statusを確認し、return
  end
end