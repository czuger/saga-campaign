namespace :bot do

  desc 'Run an auto play bot'
  task opponent_move_gangs: :environment do
    Engines::AutoPlayBot.new.run
  end

  desc 'Clear database'
  task clear_db: :environment do
    Campaign.all.each do |c|
      puts "Destroying campaign #{c.name}."
      c.winner_id = nil
      c.save!
      c.destroy
    end
  end

end
