require('dotenv').config();
import SpotifyWebApi from 'spotify-web-api-node'

$(document).on("turbolinks:load", function() {
  var spotifyApi = new SpotifyWebApi({
    clientId: process.env.SPOTIFY_CLIENT_ID,
    clientSecret: process.env.SPOTIFY_SECRET_ID,
    redirectUri: process.env.SPOTIFY_REDIRECT_URI
  });

});
