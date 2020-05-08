class
Campaign < ApplicationRecord
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

  belongs_to :winner, class_name: 'Player', optional: true

  validates :name, presence: true, uniqueness: true

  validates :campaign_mode, inclusion: { in: %w(test regular), strict: true }

  aasm do
    state :waiting_for_players, initial: true
    state :waiting_for_players_to_choose_their_faction
    state :first_hiring_and_movement_schedule, :hiring_and_movement_schedule, :bet_for_initiative
    state :troop_maintenance_required, :campaign_finished, :combat_phase

    event :players_choose_faction do
      transitions from: [:waiting_for_players], to: :waiting_for_players_to_choose_their_faction
    end

    event :players_first_hire_and_move do
      transitions from: :waiting_for_players_to_choose_their_faction, to: :first_hiring_and_movement_schedule
    end

    event :players_hire_and_move do
      transitions from: [:first_hiring_and_movement_schedule, :bet_for_initiative], to: :hiring_and_movement_schedule
    end

    event :require_troop_maintenance do
      transitions from: [:first_hiring_and_movement_schedule, :hiring_and_movement_schedule], to: :troop_maintenance_required
    end

    event :to_combat_phase do
      transitions from: [:first_hiring_and_movement_schedule, :hiring_and_movement_schedule], to: :combat_phase
    end

    event :players_bet_for_initiative do
      transitions from: [:combat_phase, :first_hiring_and_movement_schedule, :hiring_and_movement_schedule, :troop_maintenance_required], to: :bet_for_initiative
    end

    event :terminate_campaign do
      transitions from: [:combat_phase, :first_hiring_and_movement_schedule, :hiring_and_movement_schedule], to: :campaign_finished
    end
  end

  # A dangerous method that destroy all campaigns (for dev only)
  def self.cleanup
    Campaign.all.each do |c|
      c.winner_id = nil
      c.save!
      c.destroy
    end
  end

end
