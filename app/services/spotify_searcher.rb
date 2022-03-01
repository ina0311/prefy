class SpotifySearcher < SpotifyService
  def self.call(word)
    new(word).search
  end

  def initialize(word)
    @word = word
    @artists = Array.new
    @albums = Array.new
    @tracks = Array.new
  end

  def search
    response = request_search(@word)

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

    {artists: @artists, albums: @albums, tracks: @tracks}
  end

  private

  def convert_artist(response)
    Artist.new(
      spotify_id: response.id,
      name: response.name,
      image: response.images.present? ? response.images.dig(0, 'url') : 'default_image.png'
    )
  end

  def convert_album(response)
    Album.new(
      spotify_id: response.id,
      name: response.name,
      image: response.images.dig(0, 'url'),
      release_date: response.release_date,
      artist_names: response.artists.map(&:name)
    )
  end

  def convert_track(response)
    Track.new(
      spotify_id: response.id,
      name: response.name,
      duration_ms: response.duration_ms,
      album_id: response.album.id,
      image:  response.album.images.present? ? response.album.images.dig(0, 'url') : 'default_image.png',
      artist_names: response.artists.map(&:name)
    )
  end
end