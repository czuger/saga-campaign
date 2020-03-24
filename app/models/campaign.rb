class Campaign < ApplicationRecord
  belongs_to :user

  has_many :logs, dependent: :destroy
  has_many :players, dependent: :destroy
  has_many :users, through: :players

  has_many :gangs, dependent: :destroy
  has_many :units, through: :gangs

  has_many :fight_results, dependent: :destroy

  validates :name, presence: true
end
