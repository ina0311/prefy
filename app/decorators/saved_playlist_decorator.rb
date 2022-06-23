class SavedPlaylistDecorator < ApplicationDecorator
  delegate_all

  def genre_names
    genres.pluck(:name).join(',')
  end

  def artist_names
    include_artists.pluck(:name).join(',')
  end

  def max_total_duration_hour_and_min
    hour_and_ms = max_total_duration_ms.divmod(SavedPlaylist::HOUR_TO_MS)

    if hour_and_ms.first.zero?
      min = hour_and_ms.second.div(SavedPlaylist::MINUTE_TO_MS)
      "#{min}分"
    elsif hour_and_ms.second.zero?
      "#{hour_and_ms.first}時間"
    else
      min = hour_and_ms.second.div(SavedPlaylist::MINUTE_TO_MS)
      "#{hour_and_ms.first}時間#{min}分"
    end
  end
end
