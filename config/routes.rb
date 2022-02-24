Rails.application.routes.draw do
  root 'home#top'
  get '/auth/:provider/callback', to: 'api/v1/sessions#create'
  get '/auth/failure', to: 'api/v1/sessions#failure'
  namespace :api do
    namespace :v1 do
      delete '/logout', to: 'sessions#destroy'

      resources :myplaylists, controller: 'saved_playlists', as: 'saved_playlists'
      resources :playlists, only: %i[show edit] do
        resources :tracks, controller: 'playlist_of_tracks', only: %i[create destroy]
      end

      post '/search', to: 'searchs#search'
    end
  end
end
