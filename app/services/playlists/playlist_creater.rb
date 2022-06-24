class Playlists::PlaylistCreater < SpotifyService
  def self.call(user, playlist_name)
    new(user: user, playlist_name: playlist_name).create
  end

  def create
    if user.guest_user?
      Playlist.create_by_guest(user, playlist_name)
    else
      response = request_create_playlist.body
      Playlist.create_by_response!(response)
    end
  end

  private

  attr_reader :user, :playlist_name

  def request_create_playlist
    conn_request.post("users/#{user.spotify_id}/playlists") do |req|
      req.body = playlist_name.present? ? { name: playlist_name }.to_json : { name: "new playlist" }.to_json
    end
  end
end
