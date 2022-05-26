class TrackDecorator < ApplicationDecorator
  delegate_all

  def convert_ms_to_min_and_sec
    convert_ms_to_sec = object.duration_ms / 1000
    convert_min_and_sec = convert_ms_to_sec.divmod(60)
    min = convert_min_and_sec[0]
    sec = format_two_digits(convert_min_and_sec[1])
    return "#{min} :  #{sec}"
  end

  def artists
    object.artist_names.present? ? object.artist_names.join(',') : album.artists.map(&:name).join(',')
  end

  private
  
  def format_two_digits(number)
    return format("%02<number>d", number: number)
  end
end
