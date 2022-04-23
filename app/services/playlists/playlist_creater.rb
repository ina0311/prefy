class Playlists::PlaylistCreater < SpotifyService
  def self.call(user, playlist_name)
    new(user, playlist_name).create
  end

  def initialize(user, playlist_name)
    @user = user
    @playlist_name = playlist_name
  end

  def create
    if @user.guest_user?
      Playlist.create_by_guest(@user, @playlist_name)
    else
      response = request_create_playlist
      Playlist.create_by_response(response.body)
    end
  end

  private

  def request_create_playlist
    response = conn_request.post("users/#{@user.spotify_id}/playlists") do |req|
      req.body = @playlist_name.present? ? { name: @playlist_name }.to_json : { name: "new playlist" }.to_json
    end
  end
end