module ErrorsHandler
  extend ActiveSupport::Concern

  class NotCreatePlaylistError < StandardError; end
  class UnableToGetPlaylistOfTracksError < StandardError; end
  class NotUpdateSavedPlaylistError < StandardError; end
  class NotGetTracksByTargetArtists; end
  class NotEnoughTrackInPlaylist; end
  class NotEnoughPlaybackTimeForPlaylist; end
  class AccessTokenExpiration < StandardError; end

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ErrorsHandler::UnableToGetPlaylistOfTracksError, with: :unable_to_get_tracks
    rescue_from ErrorsHandler::NotUpdateSavedPlaylistError, with: :not_update_saved_playlist
    rescue_from ErrorsHandler::NotEnoughTrackInPlaylist, with: :not_enough_track_in_playlist
    rescue_from ErrorsHandler::NotEnoughPlaybackTimeForPlaylist, with: :not_enough_playback_time_for_playlist
    rescue_from ErrorsHandler::AccessTokenExpiration, with: :access_token_expiration
  end

  private

  def not_enough_track_in_playlist
    flash[:warning] = t("message.not_get", item: '曲数')
  end

  def not_enough_playback_time_for_playlist
    flash[:warning] = t("message.few_track_fit_criteria")
    flash[:warning] = t("message.duration_time_more_than_10_minutes_shorter")
  end

  def unable_to_get_tracks
    flash[:danger] = 'プレイリストの条件に沿った曲が取得できず,プレイリストを更新できませんでした'
    redirect_to api_v1_saved_playlist_path(@playlist)
  end

  def not_update_saved_playlist
    flash[:danger] = 'プレイリストの条件が正常に更新されませんでした'
    redirect_to api_v1_saved_playlist_path(@playlist)
  end

  def render_404(exception = nil, messages = nil)
    render_error(400, 'Bad Request', exception&.message, *messages)
  end

  def access_token_expiration
    redirect_to root_path, danger: '1時間経過したのでログアウトしました'
  end
end
