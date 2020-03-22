class FightResult < ApplicationRecord
  belongs_to :campaign

  serialize :fight_data
  serialize :fight_log
end
