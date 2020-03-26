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
    state :waiting_for_players_to_choose_their_faction, :hiring_and_movement_schedule

    event :players_choose_faction do
      transitions from: [:waiting_for_players], to: :waiting_for_players_to_choose_their_faction
    end

    event :players_hire_and_move do
      transitions from: [:waiting_for_players_to_choose_their_faction], to: :hiring_and_movement_schedule
    end

  end

end
