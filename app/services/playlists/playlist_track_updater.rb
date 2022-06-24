class Playlists::PlaylistTrackUpdater < SpotifyService
  def self.call(user, playlist, track_response)
    new(user, playlist, track_response).update
  end

  def initialize(user, playlist, track_response)
    ramdom_track_ids = track_response[:ramdom_tracks].map { |h| h[:spotify_id] }
    target_track_ids = track_response[:target_tracks].flatten.map { |h| h[:spotify_id] } if track_response[:target_tracks]
    track_ids = target_track_ids ? ramdom_track_ids.concat(target_track_ids).shuffle : ramdom_track_ids.shuffle
    super(user: user, playlist: playlist, track_ids: track_ids)
  end

  def update
    unless user.guest_user?
      query = track_ids.join(',spotify:track:')
      request_playlist_tracks_update(query)
    end
    playlist_of_tracks_update!
  end

  private

  attr_reader :user, :playlist, :track_ids

  def playlist_of_tracks_update!
    Tracks::TrackInfoGetter.call(user, track_ids)
    PlaylistOfTrack.all_update(playlist, track_ids)
  end

  def request_playlist_tracks_update(query)
    conn_request.put("playlists/#{playlist.spotify_id}/tracks?uris=spotify:track:#{query}").status
  end
end
