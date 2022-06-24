class Players::DeviceGetter < SpotifyService
  def self.call(user)
    new(user: user).request
  end

  def request
    response = request_device
    return false unless response.success?

    devices = response.body[:devices]
    devices.find { |d| d[:is_active] || !d[:is_restricted] }[:id]
  end

  private

  attr_reader :user

  def request_device
    conn_request.get('me/player/devices')
  end
end
