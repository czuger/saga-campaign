class Photo < ApplicationRecord
  belongs_to :player

  def path
    "/photos/#{player_id}/#{fight_result_id}/"
  end

  def file_path
    path + filename
  end

end
