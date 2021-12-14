module Constants
  IMAGES = ['ugc-image-upload'].freeze
  SPOTIFYCONNECT = ['user-read-playback-state', 'user-modify-playback-state', 'user-read-currently-playing'].freeze
  USERS = ['user-read-private'].freeze
  FOLLOW = ['user-follow-modify', 'user-follow-read'].freeze
  LIBRARY = ['user-library-modify', 'user-library-read'].freeze
  PLAYBACK = ['streaming'].freeze
  LISTENINGHISTORY = ['user-top-read', 'user-read-recently-played'].freeze
  PLAYLISTS = ['playlist-modify-private', 'playlist-read-collaborative', 'playlist-read-private', 'playlist-modify-public'].freeze

  AUTHORIZATIONSCOPES = [IMAGES + SPOTIFYCONNECT + USERS + FOLLOW + LIBRARY + PLAYBACK + LISTENINGHISTORY + PLAYLISTS].join(' ').freeze

  AUTHORIZATIONSTRING = [ENV['SPOTIFY_CLIENT_ID'] + ':' + ENV['SPOTIFY_SECRET_ID']].join.freeze
end