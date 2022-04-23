class Players::TrackPause < SpotifyService
  def self.call(user, device)
    new(user, device,).pause
  end

  def initialize(user, device)
    @user = user
    @device = device
  end

  def pause
    request_player_pause
  end

  private

  def request_player_pause
    conn_request.put("me/player/pause?device_id=#{@device}")
  end
end