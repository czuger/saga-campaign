class Gang < ApplicationRecord
  belongs_to :campaign
  belongs_to :player

  has_many :units, dependent: :delete_all
end
