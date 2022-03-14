class Api::V1::SavedPlaylistsController < ApplicationController
  before_action :delete_playlist_id, only: %i[index new]

  def index
    # ユーザーのプレイリストの情報を所得
    Users::UserPlaylistsGetter.call(current_user) unless current_user.guest_user?
    @saved_playlists = current_user.saved_playlists.includes(:playlist)
  end

  def new
    @form = SavedPlaylistForm.new
  end

  def create
    @playlist = Playlists::PlaylistCreater.call(current_user, playlist_name_params)
    @form = SavedPlaylistForm.new(saved_playlist_params)
 
    if @form.save(@form.artist_ids, @form.genre_ids)
      @saved_playlist = SavedPlaylist.find_by(playlist_id: @form.playlist_id)
    else
      render :new
    end

    @playlist_of_tracks = SavedPlaylists::BasedOnSavedPlaylistTracksGetter.call(@saved_playlist)
    Playlists::PlaylistTrackUpdater.call(current_user, @saved_playlist.playlist_id, @playlist_of_tracks.pluck(:spotify_id))
    # TODO エラー処理

    redirect_to api_v1_playlist_path(@playlist.spotify_id)
  end

  def update
    @playlist = Playlist.find(playlist_params)
    @form = SavedPlaylistForm.new(saved_playlist_params)

    if @form.save(@form.artist_ids, @form.genre_ids)
      @saved_playlist = SavedPlaylist.find_by(playlist_id: @form.playlist_id)
      track_ids = PlaylistOfTrack.where(playlist_id: @playlist_id).pluck(:track_id)
      Playlists::PlaylistTracksRemover.call(current_user, @playlist.spotify_id, track_ids) if track_ids.present?
    else
      redirect_back(fallback_location: root_path)
    end

    @playlist_of_tracks = SavedPlaylists::BasedOnSavedPlaylistTracksGetter.call(@saved_playlist)
    Playlists::PlaylistTrackUpdater.call(current_user, @saved_playlist.playlist_id, @playlist_of_tracks.pluck(:spotify_id))

    redirect_to api_v1_playlist_path(@playlist.spotify_id)
  end

  private

  def saved_playlist_params
    params.require(:saved_playlist).permit(
      :only_follow_artist,
      :that_generation_preference,
      :period,
      :max_total_duration_ms,
      :max_number_of_track,
    ).merge(
      since_year: params[:saved_playlist][:since_year],
      before_year: params[:saved_playlist][:before_year],
      duration_hour: params[:saved_playlist][:duration_hour].to_i,
      duration_minute: params[:saved_playlist][:duration_minute].to_i,
      artist_ids: params[:artist_ids],
      genre_ids: params[:genre_ids]&.map(&:to_i),
      user_id: current_user.id,
      playlist_id: @playlist.id
    )
  end

  def playlist_name_params
    params.require(:saved_playlist).permit(:playlist_name)[:playlist_name]
  end

  def playlist_params
    params.require(:id)
  end
end
