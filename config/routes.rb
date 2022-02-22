Rails.application.routes.draw do
  root 'home#top'
  get '/auth/:provider/callback', to: 'api/v1/sessions#create'
  get '/auth/failure', to: 'api/v1/sessions#failure'
  namespace :api do
    namespace :v1 do
      delete '/logout', to: 'sessions#destroy'

      resources :myplaylists, controller: 'saved_playlists', expect: %i[show], as: 'saved_playlists'
      resources :playlists, only: %i[show edit] do
        resources :playlist_of_tracks, only: %i[create destroy], path: 'tracks'
      end
      
    end
  end
end
