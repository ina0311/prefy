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
    if current_user.guest_user?
      @playlist = Playlist.create_by_guest(current_user, playlist_name_params)
    else
      playlist_response = Playlists::PlaylistCreater.call(current_user, playlist_name_params)   
      @playlist = Playlist.create_by_response!(playlist_response)
    end

    @form.playlist_id = @playlist.spotify_id

    if @form.save(@form.artist_ids, @form.genre_ids)
      @saved_playlist = SavedPlaylist.find_by(playlist_id: @form.playlist_id)
    else
      flash.now[:danger] = t("message.not_created", item: 'プレイリストの条件')
      render :new
    end

    ramdom_tracks, target_tracks = SavedPlaylists::BasedOnSavedPlaylistTracksGetter.call(@saved_playlist, current_user)

    raise ErrorsHandler::UnableToGetPlaylistOfTracksError unless ramdom_tracks && target_tracks

    if @saved_playlist.include_artists
      not_get_artists = @saved_playlist.has_track_by_require_artists(target_tracks)
      return if not_get_artists.blank?
      flash[:danger] = t("message.not_get_track", item: not_get_artists.join('と'))
    end

    track_ids = ramdom_tracks.concat(target_tracks.flatten).shuffle.pluck(:spotify_id)
    Playlists::PlaylistTrackUpdater.call(current_user, @playlist, tracks_ids)
    check_saved_playlist_requirements
    redirect_to api_v1_playlist_path(@playlist.spotify_id)
  end

  def update
    @playlist = Playlist.includes(:playlist_of_tracks).find(playlist_params)
    @form = SavedPlaylistForm.new(saved_playlist_params)

    raise ErrorsHandler::NotUpdateSavedPlaylistError unless @form.valid?

    @form.save(@form.artist_ids, @form.genre_ids)
    @saved_playlist = SavedPlaylist.find_by(playlist_id: @form.playlist_id)

    ramdom_tracks, target_tracks = SavedPlaylists::BasedOnSavedPlaylistTracksGetter.call(@saved_playlist)

    raise ErrorsHandler::UnableToGetPlaylistOfTracksError unless ramdom_tracks && target_tracks
    
    if @saved_playlist.include_artists
      not_get_artists = @saved_playlist.has_track_by_require_artists(target_tracks)
      return if not_get_artists.blank?
      flash[:danger] = t("message.not_get_track", item: not_get_artists.join('と'))
    end

    old_track_ids = @playlist.playlist_of_tracks.pluck(:track_id)
    Playlists::PlaylistTracksRemover.call(current_user, @playlist, old_track_ids) if old_track_ids.present?

    new_tracks_ids = ramdom_tracks.concat(target_tracks.flatten).shuffle.pluck(:spotify_id)
    Playlists::PlaylistTrackUpdater.call(current_user, @playlist, new_tracks_ids)
    check_saved_playlist_requirements
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
      artist_ids: params[:artist_ids].reject(&:empty?),
      genre_ids: params[:genre_ids].reject(&:empty?)&.map(&:to_i),
      user_id: current_user.id,
      playlist_id: @playlist&.id
    )
  end

  def playlist_name_params
    params.require(:saved_playlist).permit(:playlist_name)[:playlist_name]
  end

  def playlist_params
    params.require(:id)
  end

  def check_saved_playlist_requirements
    case 
    when @saved_playlist.number_of_track_less_than_requirements?
      flash[:warning] = t("message.not_get", item: '曲数')
    when @saved_playlist.total_duration_more_than_ten_minutes_less_than_requirement?
      flash[:warning] = t("message.few_track_fit_criteria")
      flash[:warning] = t("message.duration_time_more_than_10_minutes_shorter")
    end
  end
end
