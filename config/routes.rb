Rails.application.routes.draw do
  root 'home#top'
  namespace :api do
    namespace :v1 do
      get '/login', to: "auth#authorize"
      get '/auth', to: "auth#show"
      get '/user', to: "users#create"

      resources :playlists, only: %i[index]
    end
  end
end
