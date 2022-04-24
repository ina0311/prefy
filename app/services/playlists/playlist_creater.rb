class Playlists::PlaylistCreater < SpotifyService
  def self.call(user, playlist_name)
    new(user, playlist_name).create
  end

  def initialize(user, playlist_name)
    @user = user
    @playlist_name = playlist_name
  end

  def create
    response = request_create_playlist
    if response.success?
      response.body
    else
      false
    end
  end

  private

  attr_reader :user, :playlist_name

  def request_create_playlist
    response = conn_request.post("users/#{user.spotify_id}/playlists") do |req|
      req.body = playlist_name.present? ? { name: playlist_name }.to_json : { name: "new playlist" }.to_json
    end
  end
end