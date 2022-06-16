class Players::TrackStarter < SpotifyService
  def self.call(user, device, type, id)
    new(user, device, type, id).start
  end

  def initialize(user, device, type, id)
    @user = user
    @device = device
    @type = type
    @id = id
  end

  def start
    binding.pry
    uri = "spotify:#{type}:#{id}"
    request_body = create_request_body(uri)
    request_player_start(request_body)
  end

  private

  attr_reader :user, :device, :type, :id

  def request_player_start(request_body)
    conn_request.put("me/player/play?device_id=#{device}") do |req|
      req.body = request_body.to_json
    end
  end

  def create_request_body(uri)
    if type == 'playlist'
      {
        context_uri: uri,
        offset: { 
          position: 0 
        },
        position_ms: 0
      }
    elsif type == 'track'
      {
        context_uri: uri
      }
    end
  end
end