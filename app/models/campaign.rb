class Campaign < ApplicationRecord
  include AASM

  belongs_to :user

  has_many :logs, dependent: :destroy
  has_many :players, dependent: :destroy
  has_many :users, through: :players

  has_many :gangs, dependent: :destroy
  has_many :units, through: :gangs

  has_many :fight_results, dependent: :destroy

  validates :name, presence: true

  aasm do
    state :waiting_for_players, initial: true
    state :waiting_for_players_to_choose_their_faction

    event :players_choose_faction do
      transitions [:waiting_for_players] => :waiting_for_players_to_choose_their_faction
    end
  end

end
