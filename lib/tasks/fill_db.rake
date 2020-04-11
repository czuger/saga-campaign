namespace :fill_db do
  desc 'Opponents choose factions'
  task opponent_choose_faction: :environment do

    Player.where( user_id: 2, faction: nil ).each do |p|
      p p
      p.faction = 'morts'
      p.save!
    end

  end

end
