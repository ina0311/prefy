class Players::TrackStarter < SpotifyService
  def self.call(user, device, type, object)
    new(user, device, type, object).start
  end

  def initialize(user, device, type, object)
    @user = user
    @device = device
    @type = type
    @object = object
  end

  def start
    request_body = create_request_body
    request_player_start(request_body)
  end

  private

  attr_reader :user, :device, :type, :object

  def request_player_start(request_body)
    conn_request.put("me/player/play?device_id=#{device}") do |req|
      req.body = request_body.to_json
    end
  end

  def create_request_body
    {
      context_uri: "spotify:#{type}:#{return_id_by_class}",
      offset: { 
        position: object.position 
      },
      position_ms: 0
    }
  end

  def return_id_by_class
    if object.class == PlaylistOfTrack
      return object.playlist_id
    elsif object.class == Track
      return object.album_id
    end
  end
  
end