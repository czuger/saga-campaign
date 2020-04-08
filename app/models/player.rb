class Player < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  has_many :gangs, dependent: :destroy

  # validates :faction, presence: true

  serialize :controls_points
end
