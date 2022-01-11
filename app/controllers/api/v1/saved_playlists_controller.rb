class Api::V1::SavedPlaylistsController < ApplicationController

  def index
    # ユーザーのプレイリストを所得
    response = conn_request.get('me/playlists').body[:items]

    # 取得したプレイリストの情報を元に元からあればfind、なければcreate
    @saved_playlists = current_user.saved_playlists.find_or_create_savedplaylists(response)
  end

  def new
    @form = SavedPlaylistForm.new
  end

  def create
    @playlist = conn_request_playlist
    @form = SavedPlaylistForm.new(saved_playlist_params)

    if @form.save(@form.artist_ids, @form.genre_ids, @form.track_ids)
      redirect_to api_v1_playlist_path(@playlist.id)
    else
      render :new
    end
  end

  private

  def saved_playlist_params
      params.require(:saved_playlist).permit(
        :only_follow_artist,
        :that_generation_preference,
        :since_year,
        :before_year,
        :max_total_duration_ms,
        :max_number_of_track,
      ).merge(
        artist_ids: params[:artist_ids]&.map(&:to_i),
        genre_ids: params[:genre_ids]&.map(&:to_i),
        track_ids: params[:track_ids]&.map(&:to_i),
        user_id: current_user.id,
        playlist_id: @playlist.id
      )
  end
end
