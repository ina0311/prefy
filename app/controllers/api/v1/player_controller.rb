class Api::V1::PlayerController < ApplicationController
  def play
    id = player_params[:id]
    position = player_params[:position]
    @type = player_params[:type]
    @object = @type == 'playlist' ? PlaylistOfTrack.find(id) : Track.new(album_id: id, position: position)
    device = Players::DeviceGetter.call(current_user)
    Players::TrackStarter.call(current_user, device, @type, @object)
  end

  private

  def player_params
    params.permit(:id, :type, :position)
  end
end
