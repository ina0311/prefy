class Players::TrackStarter < SpotifyService
  def self.call(user, device, request_body)
    new(user, device, request_body).start
  end

  def initialize(user, device, request_body)
    @user = user
    @device = device
    @request_body = request_body
  end

  def start
    request_player_start
  end

  private

  attr_reader :user, :device, :request_body

  def request_player_start
    conn_request.put("me/player/play?device_id=#{device}") do |req|
      req.body = request_body.to_json
    end
  end
end