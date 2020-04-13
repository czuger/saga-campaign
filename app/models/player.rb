class Player < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  has_many :gangs, dependent: :destroy

  # validates :faction, presence: true
  validates :pp, presence: true

  serialize :controls_points

  def self.create_new_player( campaign, user )
    player = Player.create(
      user: user, campaign: campaign, pp: GameRules::Factions::START_PP )

    campaign.logs.create!( data: "Joueur #{user.name} ajouté à la campagne.")
    player
  end
end
