Rails.application.routes.draw do
  root 'home#top'
  namespace :api do
    namespace :v1 do
      get '/login', to: "auth#authorize"
      get '/callback', to: "sessions#callback"

      resources :playlists, only: %i[index]
    end
  end
end
