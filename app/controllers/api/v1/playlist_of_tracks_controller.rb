class Api::V1::PlaylistOfTracksController < ApplicationController
  def create
    playlist_of_track = PlaylistOfTrack.new(playlist_id: playlist_of_track_params[:playlist_id], track_id: playlist_of_track_params[:track_id])
    @playlist_of_track = Playlists::PlaylistTrackAdder.call(current_user, playlist_of_track)
    js_format_flash_message(:success, "プレイリストに曲を追加しました")
  end

  def destroy
    playlist_of_track = PlaylistOfTrack.find(playlist_of_track_params[:id])
    Playlists::PlaylistTrackRemover.call(current_user, playlist_of_track)
    @playlist_of_tracks = PlaylistOfTrack.includes(track: [album: :artists]).where(playlist_id: playlist_of_track.playlist_id)
    js_format_flash_message(:success, "プレイリストから曲を削除しました")
  end

  private

  def playlist_of_track_params
    params.permit(:id, :playlist_id, :track_id)
  end

  def js_format_flash_message(type, message)
    respond_to do |format|
      format.js { flash.now[type] = message }
    end
  end
end
