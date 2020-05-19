class Log < ApplicationRecord
  belongs_to :campaign
  belongs_to :player

  serialize :translation_data
end
