class TrackDecorator < ApplicationDecorator
  delegate_all

  def convert_ms_to_min_and_sec
    convert_ms_to_sec = object.duration_ms / 1000
    convert_min_and_sec = convert_ms_to_sec.divmod(60)
    min = convert_min_and_sec[0]
    sec = format_two_digits(convert_min_and_sec[1])
    "#{min} :  #{sec}"
  end

  def artists
    artist_names.present? ? artist_names.join(',') : album.artists.map(&:name).join(',')
  end

  private

  def format_two_digits(number)
    format("%02<number>d", number: number)
  end
end
