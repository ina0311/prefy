class Genre < ApplicationRecord
  has_many :artist_genres, dependent: :destroy
  has_many :saved_playlist_genres, dependent: :destroy

  validates :name, uniqueness: true, format: { with: /[\w\-& ]+/ }

  scope :only_names, -> { pluck(:name).map(&:downcase) }
  scope :search_by_names, ->(artist_genres) { where(name: artist_genres.pluck(:genres).flatten.uniq) }
  scope :order_by_ids_search, ->(ids) { where(id: ids).order([Arel.sql('field(id, ?)'), ids]) }
  
  def self.all_import(genres_names)
    Genre.transaction do
      genres = genres_names.map { |name| Genre.new(name: name) }
      Genre.import!(genres, ignore: true)
    end
  end
end
