class Campaign < ApplicationRecord
  belongs_to :user

  has_many :logs, dependent: :destroy
  has_many :players, dependent: :destroy
  has_many :users, through: :players

  has_many :gangs, dependent: :destroy

  validates :name, presence: true
end
