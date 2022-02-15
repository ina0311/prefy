class Playlists::PlaylistCreater < SpotifyService
  def self.call(user, playlist_name)
    new(user, playlist_name).create
  end

  def initialize(user, playlist_name)
    @user = user
    @playlist_name = playlist_name
  end

  def create
    response = request_create_playlist(@user, @playlist_name)
    Playlist.create_by_response(response.body)
  end
end