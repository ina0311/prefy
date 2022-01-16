class Genre < ApplicationRecord
  has_many :track_genres, dependent: :destroy
  has_many :saved_playlist_genres, dependent: :destroy

  validates :name, uniqueness: true
  
  def self.all_import(genres_names)
    Genre.transaction do
      genres = genres_names.map { |name| Genre.new(name: name) }
      Genre.import!(genres)
    end
  end
end
