class Gang < ApplicationRecord
  belongs_to :campaign
  belongs_to :player

  has_many :units, dependent: :delete_all

  validates :name, presence: true

  serialize :movements

  def get_next_movement!
    movement = self.movements.shift
    save!
    movement
  end

end
