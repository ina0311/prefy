class Users::UserPlaylistsGetter < SpotifyService
  def self.call(user)
    new(user: user).get
  end

  def get
    response = request_saved_playlists
    Playlist.all_update(response)
    defaults = user.my_playlists.pluck(:spotify_id)
    now = response.map { |res| res[:id] }
    delete_playlists = defaults - now
    add_playlists = now - defaults
    [add_playlists, delete_playlists]
  end

  private

  attr_reader :user

  def request_saved_playlists
    playlists = []
    offset = 0
    loop do
      response = conn_request.get("users/#{user.spotify_id}/playlists?limit=50&offset=#{offset}")
      playlists.concat(response.body[:items])
      break if response.body.size <= 49

      offset += 50
    end

    playlists
  end
end
