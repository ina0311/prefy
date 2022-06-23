class SpotifySearcher < SpotifyService
  def self.call(word, user)
    new(word: word, user: user)
  end

  def search
    type = 'artist,album,track'
    response = request_search(type)

    artists = response[:artists][:items].present? ? convert_artists(response[:artists][:items]) : nil
    albums = response[:albums][:items].present? ? convert_albums(response[:albums][:items]) : nil
    tracks = response[:tracks][:items].present? ? convert_tracks(response[:tracks][:items]) : nil
    return nil unless [artists, albums, tracks].any?

    { artists: artists, albums: albums, tracks: tracks }
  end

  def artists
    type = 'artist'
    response = request_search(type)
    artists = convert_artists(response[:artists][:items])
    return nil if artists.blank?

    artists
  end

  private

  attr_reader :word, :user

  def convert_artists(artist_items)
    artist_items.map do |item|
      Artist.new(
        spotify_id: item[:id],
        name: item[:name],
        image: item[:images].dig(0, :url)
      )
    end
  end

  def convert_albums(album_items)
    album_items.map do |item|
      Album.new(
        spotify_id: item[:id],
        name: item[:name],
        image: item[:images].dig(0, :url),
        release_date: item[:release_date],
        artist_names: item[:artists].map { |artist| artist[:name] }
      )
    end
  end

  def convert_tracks(track_items)
    track_items.map do |item|
      Track.new(
        spotify_id: item[:id],
        name: item[:name],
        duration_ms: item[:duration_ms],
        position: item[:track_number],
        album_id: item[:album][:id],
        album_name: item[:album][:name],
        image: item[:album][:images].dig(0, :url),
        artist_ids: item[:artists].map { |artist| artist[:id] },
        artist_names: item[:artists].map { |artist| artist[:name] }
      )
    end
  end

  def request_search(type)
    conn_request.get("search?q=#{word}&type=#{type}&limit=20").body
  end
end
