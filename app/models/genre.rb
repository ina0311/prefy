class Genre < ApplicationRecord
  has_many :artist_genres, dependent: :destroy
  has_many :saved_playlist_genres, dependent: :destroy

  validates :name, uniqueness: true, format: { with: /[\w\-& ]+/ }

  attribute :count, :integer

  scope :only_names, -> { pluck(:name).map(&:downcase) }
  scope :search_by_names, ->(hash) { where(name: hash.pluck(:genre_names).flatten.uniq) }
  scope :order_by_ids_search, ->(ids) { where(id: ids).order([Arel.sql('field(id, ?)'), ids]) }
  
  def self.all_import!(response)
    Genre.transaction do
      genres_names = response.map { |res| res[:genres] }.flatten.uniq
      genres = genres_names.map { |name| Genre.new(name: name) }
      Genre.import!(genres, ignore: true)
    end
  end
end
