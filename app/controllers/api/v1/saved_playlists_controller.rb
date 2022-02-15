class Api::V1::SavedPlaylistsController < ApplicationController
include PlaylistCompose

  def index
    # ユーザーのプレイリストの情報を所得
    playlist_attributes = conn_request_saved_playlists
    @saved_playlists = SavedPlaylist.list_get(playlist_attributes, current_user)
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
    albums = Albums::AlbumRegistrar.call(@playlist_of_tracks)
    Artists::ArtistRegistrar.call(albums_convert_artist_ids(albums), albums)
    Playlists::TrackUpdater.call(current_user, @saved_playlist.playlist_id, @playlist_of_tracks)
    # TODO エラー処理

    redirect_to api_v1_playlist_path(@playlist.id)
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

  def albums_convert_artist_ids(albums)
    albums.flatten.map { |a| a.artists.map(&:id) }
  end
end
