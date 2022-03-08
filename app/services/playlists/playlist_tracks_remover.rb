class Playlists::PlaylistTracksRemover < SpotifyService
  def self.call(user, playlist_id, track_ids)
    new(user, playlist_id, track_ids).remove
  end

  def initialize(user, playlist_id, track_ids)
    @user = user
    @playlist_id = playlist_id
    @track_ids = track_ids
  end

  def remove
    unless guest_user?(@user)
      request_bodys = @track_ids.instance_of?(Array) ? create_request_body : {tracks: [{uri: "spotify:track:#{@track_ids}"}]}
      response = request_remove_playlist_tracks(@user, @playlist_id, request_bodys)
    end
    PlaylistOfTrack.specific(@playlist_id, @track_ids).delete_all
  end

  private

  attr_reader :playlsit_id, :user

  def create_request_body
    request_bodys = []
    offset = 0
    track_uris = @track_ids.map { |id| {uri: "spotify:track:#{id}"} }
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