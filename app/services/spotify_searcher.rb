class SpotifySearcher < SpotifyService
  def self.call(word, user)
    new(word, user)
  end

  def initialize(word, user)
    @word = URI.encode_www_form_component(word)                                                               
    @user = user
  end

  def search
    type = 'artist,album,track'

    response = request_search(type)
    return nil if response.empty?

    artists = convert_artists(response[:artists][:items])
    albums = convert_albums(response[:albums][:items])
    tracks = convert_tracks(response[:tracks][:items])

    return {artists: artists, albums: albums, tracks: tracks}
  end

  def artists
    type = 'artist'
    response = request_search(type)
    artists = convert_artists(response[:artists][:items])
  end

  private

  attr_reader :word, :user

  def convert_artists(artist_items)
    artists = artist_items.map do |item|
                Artist.new(
                  spotify_id: item[:id],
                  name: item[:name],
                  image: item[:images].dig(0, :url)
                )
              end
    return artists
  end

  def convert_albums(album_items)
    albums = album_items.map do |item|
              Album.new(
                 spotify_id: item[:id],
                 name: item[:name],
                 image: item[:images].dig(0, :url),
                 release_date: item[:release_date],
                 artist_names: item[:artists].map { |artist| artist[:name] }
               )
             end
    return albums
  end

  def convert_tracks(track_items)
    tracks = track_items.map do |item|
               Track.new(
                 spotify_id: item[:id],
                 name: item[:name],
                 duration_ms: item[:duration_ms],
                 album_id: item[:album][:id],
                 album_name: item[:album][:name],
                 image: item[:album][:images].dig(0, :url),
                 artist_ids: item[:artists].map { |artist| artist[:id] },
                 artist_names: item[:artists].map { |artist| artist[:name] }
               )
              end
    return tracks
  end

  def request_search(type)
    conn_request.get("search?q=#{word}&type=#{type}&limit=20").body
  end
end