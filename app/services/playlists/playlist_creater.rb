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
      response = request_create_playlist(@user, @playlist_name)
      Playlist.create_by_response(response.body)
    end
  end
end