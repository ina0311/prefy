class Album < ApplicationRecord
  belongs_to :artist
  has_many :tracks, dependent: :destroy
end
