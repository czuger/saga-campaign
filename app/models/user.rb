class User < ApplicationRecord

  has_many :unit_old_libe_strings
  has_many :players

  has_many :owned_campaigns, class_name: 'Campaign'
  has_many :participating_campaigns, through: :players, class_name: 'Campaign', source: 'campaign'

  def self.find_or_create_from_auth_hash(auth_hash)

    pp auth_hash

    User.find_or_create_by!( provider: auth_hash['provider'], uid: auth_hash['uid'] ) do |user|
      user.name = auth_hash['info']['name']
      user.icon_url = auth_hash['info']['image']
    end
  end
end