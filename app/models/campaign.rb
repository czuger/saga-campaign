class Campaign < ApplicationRecord
  include AASM

  belongs_to :user

  has_many :logs, dependent: :destroy
  has_many :fight_results, dependent: :destroy
  has_many :movements_results, dependent: :destroy

  has_many :players, dependent: :destroy
  has_many :users, through: :players
  has_many :victory_points_histories, through: :players

  has_many :gangs, dependent: :destroy
  has_many :units, through: :gangs

  has_one :winner, class_name: 'Player'

  validates :name, presence: true, uniqueness: true

  aasm do
    state :waiting_for_players, initial: true
    state :waiting_for_players_to_choose_their_faction
    state :first_hiring_and_movement_schedule, :hiring_and_movement_schedule, :bet_for_initiative
    state :campaign_finished

    event :players_choose_faction do
      transitions from: [:waiting_for_players], to: :waiting_for_players_to_choose_their_faction
    end

    event :players_first_hire_and_move do
      transitions from: :waiting_for_players_to_choose_their_faction, to: :first_hiring_and_movement_schedule
    end

    event :players_hire_and_move do
      transitions from: [:first_hiring_and_movement_schedule, :bet_for_initiative], to: :hiring_and_movement_schedule
    end

    event :players_bet_for_initiative do
      transitions from: [:first_hiring_and_movement_schedule, :hiring_and_movement_schedule], to: :bet_for_initiative
    end

    event :terminate_campaign do
      transitions from: [:bet_for_initiative], to: :campaign_finished
    end
  end

end
