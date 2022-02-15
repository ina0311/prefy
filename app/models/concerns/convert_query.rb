module ConvertQuery
  extend ActiveSupport::Concern

  def convert_querys(fillter)
    @query = String.new
    @query += "year:#{fillter[:period]}" if fillter[:period].present?
    querys = fillter[:artists].present? ? add_artists(fillter[:artists]) : @query
    target_querys = add_artists(fillter[:targets]) if fillter[:targets].present?

    return querys, target_querys
  end

  private

  def add_artists(artists)
    querys = []
    artists.each do |artist|
      string = @query.dup
      string += " artist:#{artist[:name]}"
      querys << { query: string, artist_spotify_id: artist[:spotify_id] }
    end
    querys
  end
end