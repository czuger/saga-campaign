class Player < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  has_many :gangs, dependent: :destroy

  serialize :controls_points
end
