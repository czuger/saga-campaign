class MovementsResult < ApplicationRecord

  belongs_to :campaign
  belongs_to :player
  belongs_to :gang
  belongs_to :intercepted_gang, optional: true, class_name: 'Gang'.freeze

  has_one :fight_result

  serialize :interception_info
end
