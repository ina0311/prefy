class SpotifySearcher < SpotifyService
  def self.call(word, user)
    new(word, user)
  end

  def initialize(word, user)
    @word = URI.encode_www_form_component(word)                                                               
    @user = user
  end

  def search
    @artists = Array.new
    @albums = Array.new
    @tracks = Array.new
    type = 'artist,album,track'

    response = request_search(type)
    return nil if response.empty?

    response.each do |res|
      case res.type
      when 'artist'
        @artists << convert_artist(res)
      when 'album'
        @albums << convert_album(res)
      when 'track'
        @tracks << convert_track(res)
      end
    end

    return {artists: @artists, albums: @albums, tracks: @tracks}
  end

  def artists
    type = 'artist'
    response = request_search(type).body[:artists][:items]
    response.map { |res| convert_artist(res) }
  end

  private

  attr_reader :word, :user

  def convert_artist(response)
    Artist.new(
      spotify_id: response[:id],
      name: response[:name],
      image: response[:images].dig(0, :url)
    )
  end

  def convert_album(response)
    Album.new(
      spotify_id: response[:id],
      name: response[:name],
      image: response[:images].dig(0, :url),
      release_date: response[:release_date],
      artist_names: response[:artists].map(&:name)
    )
  end

  def convert_track(response)
    Track.new(
      spotify_id: response[:id],
      name: response[:name],
      duration_ms: response[:duration_ms],
      album_id: response[:album][:id],
      image: response[:album][:images].dig(0, :url),
      artist_names: response[:artists].map(&:name)
    )
  end

  def request_search(type)
    conn_request.get("search?q=#{word}&type=#{type}&limit=50")   
  end
end