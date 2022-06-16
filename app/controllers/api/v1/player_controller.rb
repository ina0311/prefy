class Api::V1::PlayerController < ApplicationController
  def play
    @id = player_params[:id]
    @type = player_params[:type]
    device = Players::DeviceGetter.call(current_user)
    Players::TrackStarter.call(current_user, device, @type, @id)
  end

  private

  def player_params
    params.permit(:id, :type)
  end
end
