class InterceptionValidator < ActiveModel::Validator
  def validate(record)
    record.interception && record.intercepted_gang_id
  end
end

class MovementsResult < ApplicationRecord

  belongs_to :campaign
  belongs_to :player
  belongs_to :gang
  belongs_to :intercepted_gang, optional: true, class_name: 'Gang'.freeze

  has_one :fight_result

  validates_with InterceptionValidator, strict: true
end
