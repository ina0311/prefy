class Genre < ApplicationRecord
  has_many :arist_genres, dependent: :destroy
  has_many :saved_playlist_genres, dependent: :destroy

  validates :name, uniqueness: true, format: { with: /[\w\-& ]+/ }

  scope :only_names, -> { pluck(:name).map(&:downcase) }
  
  def self.all_import(genres_names)
    Genre.transaction do
      genres = genres_names.map { |name| Genre.new(name: name) }
      Genre.import!(genres, ignore: true)
    end
  end
end
