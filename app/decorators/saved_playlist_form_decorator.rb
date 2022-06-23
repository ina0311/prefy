class SavedPlaylistFormDecorator < ApplicationDecorator
  delegate_all
  include ActionView::Helpers::DateHelper
  HOUR_TO_MS = 3_600_000
  MINUTE_TO_MS = 60_000

  def follow_artist_genres(user)
    Genre.order_by_ids_search(user.follow_artists.genres_id_order_desc.keys)
  end

  def generations(user)
    user_generations = []
    all_generation = SavedPlaylist.that_generation_preferences.map { |key, value| [I18n.t("enum.saved_playlist.that_generation_preference.#{key}"), value] }
    all_generation.zip(SavedPlaylist::GENERATIONS).each do |gen|
      next if user.age < gen[1]

      user_generations << gen[0]
    end
    user_generations
  end

  def years
    select_year(nil, start_year: Time.zone.today.year, end_year: 1900).scan(/\d{4}/).uniq.map(&:to_i)
  end

  def selected_since_year
    return unless period

    period.slice(/(\d{4})/, 1)
  end

  def selected_before_year
    return unless period

    period.slice(/\d{4}-(\d{4})/, 1)
  end

  def hour
    [1, 2, 3, 4, 5, 6, 7]
  end

  def minute
    [0, 10, 20, 30, 40, 50]
  end

  def set_duration_hour
    return unless max_total_duration_ms

    max_total_duration_ms / HOUR_TO_MS
  end

  def set_duration_min
    return unless max_total_duration_ms

    (max_total_duration_ms.divmod(HOUR_TO_MS)[1]) / MINUTE_TO_MS
  end

  def btn_text(action)
    if action == 'new'
      I18n.t("helpers.submit.create_item", item: I18n.t("default.playlist"))
    else
      I18n.t("helpers.submit.update_item", item: I18n.t("default.playlist"))
    end
  end
end
