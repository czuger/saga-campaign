class MovementsResult < ApplicationRecord

  belongs_to :campaign
  belongs_to :player
  belongs_to :gang

  serialize :interception
end
