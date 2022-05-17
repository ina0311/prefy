class SavedPlaylistDecorator < ApplicationDecorator
  delegate_all

  def genre_names
    self.genres.pluck(:name).join(',') 
  end

  def artist_names
    self.include_artists.pluck(:name).join(',')
  end

  def max_total_duration_hour_and_min
    hour_and_ms = self.max_total_duration_ms.divmod(SavedPlaylist::HOUR_TO_MS)
    case 
    when hour_and_ms.first.zero?
      min = hour_and_ms.second.div(SavedPlaylist::MINUTE_TO_MS)
      return "#{min}分"
    when hour_and_ms.second.zero?
      return "#{hour_and_ms.first}時間"
    else
      min = hour_and_ms.second.div(SavedPlaylist::MINUTE_TO_MS)
      return "#{hour_and_ms.first}時間#{min}分"
    end
  end
end
