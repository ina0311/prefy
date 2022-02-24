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
        @artists << res
      when 'album'
        @albums << res
      when 'track'
        @tracks << res
      end
    end

    { artists: @artists, albums: @albums, tracks: @tracks}
  end
end