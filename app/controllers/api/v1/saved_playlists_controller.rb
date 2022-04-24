class Api::V1::SavedPlaylistsController < ApplicationController
  before_action :delete_playlist_id, only: %i[index new]

  def index
    if current_user.guest_user?
      @saved_playlists = current_user.saved_playlists.includes(:playlists)
    else
      response = Users::UserPlaylistsGetter.call(current_user)
      if response
        add_playlists, delete_playlists = response
        SavedPlaylist.add_my_playlists(current_user, add_playlists) if add_playlists.present?
        SavedPlaylist.delete_from_my_playlists(current_user, delete_playlists) if delete_playlists.present?
        @saved_playlists = current_user.saved_playlists.includes(:playlist)
      else
        flash[:danger] = '保存しているプレイリストを正常に取得できませんでした'
      end
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
      flash.now[:danger] = 'プレイリストの条件が正常に作成されませんでした'
      render :new
    end

    tracks_response = SavedPlaylists::BasedOnSavedPlaylistTracksGetter.call(@saved_playlist)

    raise ErrorsHandler::UnableToGetPlaylistOfTracksError unless tracks_response
    flash[:danger] = '指定されたアーティストの曲を取得できませんでした' if require_target_track?(@saved_playlist, tracks_response)

    tracks_ids = connect_tracks_response(tracks_response)
    Playlists::PlaylistTrackUpdater.call(current_user, @playlist, tracks_ids)
    redirect_to api_v1_playlist_path(@playlist.spotify_id)
  end

  def update
    @playlist = Playlist.includes(:playlist_of_tracks).find(playlist_params)
    @form = SavedPlaylistForm.new(saved_playlist_params)

    raise ErrorsHandler::NotUpdateSavedPlaylistError unless @form.valid?

    @form.save(@form.artist_ids, @form.genre_ids)
    @saved_playlist = SavedPlaylist.find_by(playlist_id: @form.playlist_id)

    tracks_response = SavedPlaylists::BasedOnSavedPlaylistTracksGetter.call(@saved_playlist)

    raise ErrorsHandler::UnableToGetPlaylistOfTracksError unless tracks_response
    flash[:danger] = '指定されたアーティストの曲を取得できませんでした' if require_target_track?(@saved_playlist, tracks_response)

    old_track_ids = @playlist.playlist_of_tracks.pluck(:track_id)
    Playlists::PlaylistTracksRemover.call(current_user, @playlist, old_track_ids) if old_track_ids.present?

    new_tracks_ids = connect_tracks_response(tracks_response)
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

  def require_target_track?(saved_playlist, tracks_response)
    saved_playlist.include_artists.present? && tracks_response[:refined_target_tracks].nil?
  end

  def connect_tracks_response(tracks_response)
    if tracks_response[:refined_target_tracks].nil?
      tracks_response[:refined_ramdom_tracks].shuffle.pluck(:track_id)
    else
      (tracks_response[:refined_ramdom_tracks] + tracks_response[:refined_target_tracks]).shuffle.pluck(:track_id)
    end
  end

  def check_saved_playlist_requirements
    case 
    when @saved_playlist.number_of_track_less_than_requirements?
      flash[:warning] = '指定された曲数を取得できませんでした'
    when @saved_playlist.total_duration_more_than_ten_minutes_less_than_requirement?
      flash[:warning] = '条件に合う曲が少なく、指定された再生時間より10分以上再生時間が短くなりました'
    end
  end
end
