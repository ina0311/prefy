Rails.application.routes.draw do
  root 'home#top'
  get '/auth/:provider/callback', to: 'api/v1/sessions#create'
  get '/auth/failure', to: 'api/v1/sessions#failure'
  post '/guest_login', to: 'api/v1/sessions#guest_login'

  namespace :api do
    namespace :v1 do
      delete '/logout', to: 'sessions#destroy'

      resources :myplaylists, controller: 'saved_playlists', as: 'saved_playlists'
      resources :playlists, only: %i[edit] do
        resources :playlist_of_tracks, only: %i[create destroy]
      end

      resources :searchs, only: %i[index] do
        collection do
          post '/artists', to: 'searchs#artists'
        end
      end
      post '/search', to: 'searchs#search'
      
      resources :users, only: %i[show] do
        member do
          resources :follow_artists, only: %i[index create destroy]
          post "/age", to: 'users#age'
        end
      end

      get '/play', to: 'player#play'
      get '/pause', to: 'player#pause'
      get '/start', to: 'player#start'
      get '/close', to: 'player#close'
    end
  end
end
