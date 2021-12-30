class Api::V1::PlaylistsController < ApplicationController
  include RequestUrl

  def show
    @playlist = Playlist.find(params[:id])
    items = conn_request.get("playlists/#{@playlist.spotify_id}/tracks").body[:items]
    @tracks = []
    items.each do |info|
      item_info = info[:track]
      artist_info = item_info[:artists].first
      album_info = item_info[:album]
      # アーティストの取得、保存
      this_artist = Artist.find_or_create_by(
                      spotify_id: artist_info[:id],
                      name: artist_info[:name]
                    )
      
      # 取得したアーティストを関連付けてアルバムを取得、保存
      this_album = this_artist.albums.find_or_create_by(
        spotify_id: album_info[:id],
        name: album_info[:name],
        image: album_info[:images][0][:url],
        release_date: album_info[:release_date]
      )
      
      # 取得したアルバムを関連付けてトラックを取得、保存
      this_track = this_album.tracks.find_or_create_by(
        spotify_id: item_info[:id],
        name: item_info[:name],
        duration_ms: item_info[:duration_ms]
      )

      @tracks << this_track
    end
    
    binding.pry
    
  end
end
