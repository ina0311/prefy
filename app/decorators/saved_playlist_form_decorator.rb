class SavedPlaylistFormDecorator < ApplicationDecorator
  delegate_all
  include ActionView::Helpers::DateHelper
  
  def follow_artist_genres(user)
    Genre.order_by_ids_search(user.follow_artists.genres_id_order_desc.keys)
  end

  def generations
    SavedPlaylist.that_generation_preferences.keys.to_a
  end

  def years
    select_year(nil, start_year: Date.today.year, end_year: 1900).scan(/\d{4}/).uniq.map{ |s| s.to_i }
  end

  def checked_genres
    return if self.genre_ids.blank?
    self.genre_ids.map(&:genre_id)
  end
end
