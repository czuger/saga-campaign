class Gang < ApplicationRecord
  belongs_to :campaign
  belongs_to :player

  has_many :units, dependent: :delete_all

  validates :name, presence: true

  serialize :movements
  serialize :movements_backup

  def retreat!
    unless self.retreating
      retreating_location = GameRules::Factions.retreating_position( player, self )
      campaign.logs.create!( data: I18n.t( 'log.gangs.retreating', gang_name: name, location: retreating_location ) )
      self.location = retreating_location

      # We need it in order to prevent further interceptions
      self.retreating = true
      save!
    end
  end

end
