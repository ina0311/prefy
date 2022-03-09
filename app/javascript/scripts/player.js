require('dotenv').config();
var SpotifyWebApi = require('spotify-web-api-node');

var spotifyApi = new SpotifyWebApi({
  clientId: process.env.SPOTIFY_CLIENT_ID,
  clientSecret: process.env.SPOTIFY_SECRET_ID,
  redirectUri: process.env.SPOTIFY_REDIRECT_URI
});

spotifyApi.setAccessToken(gon.user.access_token)