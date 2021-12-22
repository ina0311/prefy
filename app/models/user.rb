class User < ApplicationRecord
  attr_encrypted :encrypt_access_token, key: [ENV['TOKEN_ENCRYPTION_KEY']].pack("H*")
  attr_encrypted :encrypt_refresh_token, key: [ENV['TOKEN_ENCRYPTION_KEY']].pack("H*")

  def conn_request_token
    Faraday::Connection.new(Constants::REQUESTTOKENURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
      builder.request :url_encoded
    end
  end

  def conn_request
    Faraday::Connection.new(url: Constants::BASEURL) do |builder|
      builder.response :json, parser_options: { symbolize_names: true }
    end
  end

  def conn_auth
    Faraday::Connection.new(Constants::AUTHORIZATIONURL) do |builder|
      builder.response :logger
      builder.request :url_encoded
    end
  end
end  
end
