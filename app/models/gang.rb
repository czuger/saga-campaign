class Gang < ApplicationRecord
  belongs_to :campaign
  belongs_to :player

  has_many :units, dependent: :delete_all

  validates :name, presence: true

  def get_next_movement!
    movement = nil

    if movement_1 && !movement_1.empty?
      movement = movement_1
      self.movement_1 = nil
    elsif movement_2 && !movement_2.empty?
      movement = movement_2
      self.movement_2 = nil
    end

    save!
    movement
  end

end
