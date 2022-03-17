class Api::V1::PlayerController < ApplicationController
  def play
    request_body = create_request_body(context_uri: player_params)
    Players::TrackStarter.call(current_user, current_player, request_body)
    
    session[:player] = 'active'
    session[:playing] = true
  end

  def pause
    Players::TrackPause.call(current_user, current_player)
    session[:playing] = false
  end

  def start
    response = Players::PlaybackStateGetter.call(current_user)
    if response[:type] == 'playlist'
      id = response[:uri][/spotify:playlist:(\w+)/, 1]
      position = PlaylistOfTrack.find_by(playlist_id: id, track_id: response[:track]).position
    end
    
    request_body = create_request_body(context_uri: response[:uri], position: position, position_ms: response[:position_ms])
    Players::TrackStarter.call(current_user, current_player, request_body)
    session[:playing] = true
  end

  def close    
    session.delete(:player)
    session.delete(:playing)
  end

  private

  def player_params
    params.require(:uri)
  end

  def current_player
    get_available_devices if session[:device].nil?
    @current_player ||= session[:device]
  end

  def get_available_devices
    device = Players::DeviceGetter.call(@current_user)
    session[:device] = device[:id]
  end

  def create_request_body(*arg)
    arg = arg.extract_options!
    {
      context_uri: arg[:context_uri],
      offset: { 
        position: arg[:position] || 0 
      },
      position_ms: arg[:position_ms] || 0
    }
  end
end
