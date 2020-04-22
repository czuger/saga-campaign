class VictoryPointsHistory < ApplicationRecord
  belongs_to :player

  serialize :controlled_locations
end
