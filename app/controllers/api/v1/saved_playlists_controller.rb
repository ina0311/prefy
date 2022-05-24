class Api::V1::SavedPlaylistsController < ApplicationController
  before_action :delete_playlist_id, only: %i[index new]

  def index
    if current_user.guest_user?
      @saved_playlists = current_user.saved_playlists.includes(:playlists)
    else
      response = Users::UserPlaylistsGetter.call(current_user)
      add_playlists, delete_playlists = response
      SavedPlaylist.add_my_playlists(current_user, add_playlists) if add_playlists.present?
      SavedPlaylist.delete_from_my_playlists(current_user, delete_playlists) if delete_playlists.present?
      @saved_playlists = current_user.saved_playlists.includes(:playlist)
    end
  end

  def new
    @form = SavedPlaylistForm.new
  end

  def create
    @form = SavedPlaylistForm.new(saved_playlist_params)
    @playlist = Playlists::PlaylistCreater.call(current_user, playlist_name_params) if @form.is_only_error_to_playlist_id?
    @form.playlist_id = @playlist.spotify_id

    if @form.save(@form.artist_ids, @form.genre_ids)
      @saved_playlist = SavedPlaylist.find_by(playlist_id: @form.playlist_id)
      refined_tracks_response = SavedPlaylists::BasedOnSavedPlaylistTracksGetter.call(@saved_playlist, current_user)

      raise ErrorsHandler::UnableToGetPlaylistOfTracksError unless refined_tracks_response[:ramdom_tracks] && refined_tracks_response[:target_tracks]
  
      if @saved_playlist.include_artists
        not_get_artists = @saved_playlist.not_has_track_by_require_artists(refined_tracks_response[:target_tracks])
        flash[:danger] = t("message.not_get_track", item: not_get_artists.join('と')) if not_get_artists.present?
      end

      Playlists::PlaylistTrackUpdater.call(current_user, @playlist, refined_tracks_response)
      @saved_playlist.check_saved_playlist_requirements
      redirect_to api_v1_saved_playlist_path(@saved_playlist)
    else
      flash.now[:danger] = t("message.not_created", item: 'プレイリストの条件')
      render :new
    end
  end

  def update
    @saved_playlist = SavedPlaylist.includes(:playlist).find(params[:id])
    @form = SavedPlaylistForm.new(saved_playlist_params)

    if @form.save(@form.artist_ids, @form.genre_ids)
      Playlists::PlaylistTracksAllRemover.call(current_user, @saved_playlist.playlist)
      refined_tracks_response = SavedPlaylists::BasedOnSavedPlaylistTracksGetter.call(@saved_playlist, current_user)

      raise ErrorsHandler::UnableToGetPlaylistOfTracksError if refined_tracks_response[:ramdom_tracks].nil? && refined_tracks_response[:target_tracks].nil?
      
      if @saved_playlist.include_artists
        not_get_artists = refined_tracks_response[:target_tracks].nil? ? @saved_playlist.include_artists.map(&:name) : @saved_playlist.not_has_track_by_require_artists(refined_tracks_response[:target_tracks])
        flash[:danger] = t("message.not_get_track", item: not_get_artists.join('と')) if not_get_artists.present?
      end

      Playlists::PlaylistTrackUpdater.call(current_user, @saved_playlist.playlist, refined_tracks_response)
      @saved_playlist.check_saved_playlist_requirements
      redirect_to api_v1_saved_playlist_path(@saved_playlist)
    else
      flash.now[:danger] = t("message.not_created", item: 'プレイリストの条件')
      render :new
    end
  end

  def show
    @saved_playlist = SavedPlaylist.includes(:playlist).find(params[:id])
    @form = SavedPlaylistForm.new(saved_playlist: @saved_playlist)
    Playlists::PlaylistInfoGetter.call(current_user, @saved_playlist.playlist) unless current_user.guest_user?
    @playlist_of_tracks = @saved_playlist.playlist.playlist_of_tracks.includes([track: [album: :artists]]).position_asc
    session[:playlist_id] = @saved_playlist.playlist_id
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
      artist_ids: params[:artist_ids].reject(&:empty?),
      genre_ids: params[:genre_ids].reject(&:empty?)&.map(&:to_i),
      user_id: current_user.id,
      playlist_id: @saved_playlist&.playlist_id
    )
  end

  def playlist_name_params
    params.require(:saved_playlist).permit(:playlist_name)[:playlist_name]
  end
end
