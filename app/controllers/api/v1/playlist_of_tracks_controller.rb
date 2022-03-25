class Api::V1::PlaylistOfTracksController < ApplicationController
  def update
    playlist_id, track_id = playlist_id_and_track_id(playlist_of_track_params)
    @playlist_of_track = Playlists::PlaylistTrackAdder.call(current_user, playlist_id, track_id)
    
    js_format_flash_message(:success, "プレイリストに曲を追加しました")
  end

  def destroy
    playlist_id, position = playlist_id_and_position(playlist_of_track_params)
    
    binding.pry
    
    @change_positions = PlaylistOfTrack.more_than_position(playlist_id, position).pluck(:position)
    Playlists::PlaylistTrackRemover.call(current_user, playlist_id, position)
    @updated_playlist_of_tracks = PlaylistOfTrack.greater_than_position(playlist_id, position)
    binding.pry
    
    js_format_flash_message(:success, "プレイリストから曲を削除しました")
  end

  private

  def playlist_of_track_params
    params.permit(:playlist_id, :id, :position)
  end

  def playlist_id_and_position(playlist_of_track_params)
    playlist_id = playlist_of_track_params[:playlist_id]
    position = playlist_of_track_params[:position]
    return playlist_id, position
  end

  def playlist_id_and_track_id(playlist_of_track_params)
    playlist_id = playlist_of_track_params[:playlist_id]
    track_id = playlist_of_track_params[:id]
    return playlist_id, track_id
  end

  def js_format_flash_message(type, message)
    respond_to do |format|
      format.js { flash.now[type] = message }
    end
  end
end
