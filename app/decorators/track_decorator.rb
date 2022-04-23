class TrackDecorator < ApplicationDecorator
  delegate_all

  def convert_ms_to_min_and_sec
    convert_ms_to_sec = object.duration_ms / 1000
    convert_min_and_sec = convert_ms_to_sec.divmod(60)
    return "#{convert_min_and_sec[0]}分 #{convert_min_and_sec[1]}秒"
  end

  def artists
    object.artist_names.present? ? object.artist_names.join(',') : album.artists.map(&:name).join(',')
  end
end
