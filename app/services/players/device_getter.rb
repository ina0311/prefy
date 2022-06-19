class Players::DeviceGetter < SpotifyService
  def self.call(user)
    new(user).request
  end

  def initialize(user)
    @user = user
  end

  def request
    response = request_device
    if response.status == 200
      devices = response.body[:devices]
      device = devices.find { |d| d[:is_active] || !d[:is_restricted] }[:id]
      return device
    else
      return nil
    end
  end

  private

  attr_reader :user

  def request_device
    conn_request.get('me/player/devices')
  end
end