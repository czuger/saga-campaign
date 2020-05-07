class MovementsResult < ApplicationRecord

  belongs_to :campaign
  belongs_to :player
  belongs_to :gang

  has_one :fight_result

  serialize :interception_info
end
