class Api::V1::PlayerController < ApplicationController
  def play
    session[:player] = 'active'
    session[:playing] = true
  end

  def pause
    session[:playing] = false
  end

  def start
    session[:playing] = true
  end

  def close    
    session.delete(:player)
    session.delete(:playing)
  end
end
