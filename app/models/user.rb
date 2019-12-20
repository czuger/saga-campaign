class User < ApplicationRecord

  has_many :unit_old_libe_strings

  def self.find_or_create_from_auth_hash(auth_hash)

    User.find_or_create_by!( provider: auth_hash['provider'], uid: auth_hash['uid'] ) do |user|
      user.name = auth_hash['info']['name']
      user.icon_url = auth_hash['info']['image']
    end

  end

end