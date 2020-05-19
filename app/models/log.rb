class Log < ApplicationRecord
  belongs_to :campaign

  serialize :translation_data
end
