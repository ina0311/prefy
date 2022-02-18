class Playlists::PlaylistTracksResetter < SpotifyService
  def self.call(playlist_id, user)
    new(playlist_id, user).reset
  end

  def initialize(playlist_id, user)
    @playlist_id = playlist_id
    @user = user
  end

  def reset
    tracks = PlaylistOfTrack.where(playlist_id: @playlist_id)
    return if tracks.blank?
    request_bodys = create_request_body(tracks)
    request_reset_playlist_tracks(@playlist_id, @user, request_bodys)
    PlaylistOfTrack.where(playlist_id: @playlist_id).delete_all
  end

  private

  attr_reader :playlsit_id, :user

  def create_request_body(tracks)
    request_bodys = []
    offset = 0
    track_uris = tracks.map { |track| {uri: "spotify:track:#{track.track_id}"} }
    while true
      request_bodys << {tracks: track_uris[offset, 50]}
      break if request_bodys.size == div_50(track_uris)
      offset += 50
    end
    request_bodys
  end

  def div_50(track_uris)
    size, surplus = track_uris.size.divmod(50)
    return size if surplus.zero?
    size += 1
  end
end