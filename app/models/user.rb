class User < ApplicationRecord
  attr_encrypted :access_token, key: ENV['TOKEN_ENCRYPTION_KEY']
  attr_encrypted :refresh_token, key: ENV['TOKEN_ENCRYPTION_KEY']

  validates :name, presence: true
  validates :country, presence: true
  validates :spotify_id, presence: true
end
