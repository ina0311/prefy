Rails.application.routes.draw do
  root 'home#top'
  namespace :api do
    namespace :v1 do
      get '/auth', to: 'sessions#authorize'
      get '/callback', to: 'sessions#callback'
      delete '/logout', to: 'sessions#destroy'

      get '/myplaylists', to: 'saved_playlists#index'
      resources :playlists, only: %i[show]
    end
  end
end
