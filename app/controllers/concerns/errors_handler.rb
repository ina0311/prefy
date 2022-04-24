module ErrorsHandler
  extend ActiveSupport::Concern

  class NotCreatePlaylistError < StandardError; end
  class UnableToGetPlaylistOfTracksError < StandardError; end
  class NotUpdateSavedPlaylistError < StandardError; end

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ErrorsHandler::UnableToGetPlaylistOfTracksError, with: :unable_to_get_tracks
    rescue_from ErrorsHandler::NotUpdateSavedPlaylistError, with: :not_update_saved_playlist
  end

  private

  def unable_to_get_tracks
    flash[:danger] = 'プレイリストの条件に沿った曲が取得できず,プレイリストを更新できませんでした'
    redirect_to api_v1_playlist_path(@playlist)
  end

  def not_update_saved_playlist
    flash[:danger] = 'プレイリストの条件が正常に更新されませんでした'
    redirect_to api_v1_playlist_path(@playlist)
  end

  def render_404(exception = nil, messages = nil)
    render_error(400, 'Bad Request', exception&.message, *messages)
  end
end