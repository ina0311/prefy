class Players::PlaybackStateGetter < SpotifyService
  def self.call(user)
    new(user).get
  end

  def initialize(user)
    @user = user
  end

  def get
    response = request_playback_state
    if response.status == 200
      position_ms = response.body[:progress_ms]
      context_uri = response.body[:context][:uri]
      track = response.body[:item][:id]
      type = response.body[:context][:type]
      return { uri: context_uri, track: track , position_ms: position_ms, type: type}
    end
  end

  private

  def request_playback_state
    conn_request.get('me/player')
  end
end