require 'csv'

guest_user = User.create(
        spotify_id: 'guest_user',
        name: 'guest_user',
        country: 'JP'
      )

follow_artist_ids = []
artist_genres = []

CSV.foreach('db/guest_user/follow_artists.csv') do |row|
  artist = Artist.find_or_create_by!(
                spotify_id: row[0],
                name: row[1],
                image: row[2]
              )
  follow_artist_ids << artist.spotify_id

  genres = row[3..].map {|name| Genre.new(name: name) } 
  Genre.import!(genres, ignore: true)

  genre_ids = Genre.where(name: genres.map(&:name)).ids
  artist_genres.concat(genre_ids.map { |id| artist.artist_genres.new(genre_id: id) })
end

ArtistGenre.import!(artist_genres, ignore: true)
follow_artists = follow_artist_ids.map { |id| guest_user.follow_artists.new(artist_id: id) }
FollowArtist.import!(follow_artists, ignore: true)
