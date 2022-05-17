class SavedPlaylistFormDecorator < ApplicationDecorator
  delegate_all
  include ActionView::Helpers::DateHelper
  HOUR_TO_MS = 3600000
  MINUTE_TO_MS = 60000
  
  def follow_artist_genres(user)
    return Genre.order_by_ids_search(user.follow_artists.genres_id_order_desc.keys)
  end

  def generations(user)
    user_generations = []
    array = SavedPlaylist.that_generation_preferences.keys.map { |key| [key.titleize, key] }
    array.zip(SavedPlaylist::GENERATIONS).each do |gen|
      user_generations << gen[0] if user.age >= gen[1]
    end
    return user_generations
  end

  def years
    return select_year(nil, start_year: Date.today.year, end_year: 1900).scan(/\d{4}/).uniq.map{ |s| s.to_i }
  end

  def selected_since_year
    return unless self.period

    since_year = self.period.slice(/(\d{4})/, 1)
    return since_year
  end

  def selected_before_year
    return unless self.period

    before_year = self.period.slice(/\d{4}-(\d{4})/, 1)
    return before_year
  end

  def set_duration_hour
    return unless self.max_total_duration_ms
    
    duration_hour = self.max_total_duration_ms / HOUR_TO_MS
    return duration_hour
  end

  def set_duration_min
    return unless self.max_total_duration_ms
    
    duration_min = (self.max_total_duration_ms.divmod(HOUR_TO_MS)[1]) / MINUTE_TO_MS
    return duration_min
  end

  def set_that_generation_preference
    return nil unless self.that_generation_preference
    
    return SavedPlaylist.that_generation_preferences.keys[self.that_generation_preference]
  end
end
