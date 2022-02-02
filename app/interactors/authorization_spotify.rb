class AuthorizationSpotify
  include Interactor::Organizer

  organize CreateRequest, RequestAuthorization
end
