class Api::V1::SavedPlaylistsController < ApplicationController
  include RequestUrl

  def index
    # ユーザーのプレイリストを所得
    response = conn_request.get('me/playlists').body[:items]

    # 取得したプレイリストの情報を元に元からあればfind、なければcreate
    @saved_playlists = current_user.saved_playlists.find_or_create_savedplaylists(response)
  end
end
