class SavedPlaylistDecorator < ApplicationDecorator
  delegate_all

  def genre_names
    self.genres.pluck(:name).join(',') 
  end

  def artist_names
    self.include_artists.pluck(:name).join(',')
  end
end
