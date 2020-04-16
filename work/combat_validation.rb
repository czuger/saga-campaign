require 'active_record'
require 'hazard'
require 'pp'
require 'i18n'
require 'open_hash'

require_relative '../app/models/application_record'
require_relative '../app/models/gang'
require_relative '../app/models/player'
require_relative '../app/models/user'
require_relative '../app/models/unit'
require_relative '../app/models/fight_result'
require_relative '../app/models/fight/base'
require_relative '../app/models/fight/attack_atomic_step'
require_relative '../app/models/fight/attack_with_retaliation'
require_relative '../app/models/fight/attack_count_points'
require_relative '../app/models/fight/tmp_gang'
require_relative '../app/models/fight/tmp_unit'
require_relative '../app/models/fight/action_dice_pool'
require_relative '../app/models/fight/action_decision'
require_relative '../app/models/fight/hits_assignment'
require_relative '../app/models/fight/casualties_unit'

db = YAML.load_file( 'config/database.yml' )['development']
db['pool'] = 5

ActiveRecord::Base.establish_connection(db )

I18n.config.load_path += Dir['config/locales/**/*.{rb,yml,yaml}']

I18n.config.available_locales = [ :fr, :en ]
I18n.default_locale = :fr

def stats
  results = {}
  lords_surviving_count = 0

  total_amount_of_units = 0
  total_remaining_units = 0

  runs = 1000

  1.upto(runs) do |i|
    p i if i % 100 == 0

    f = Fight::Base.new(2, 'O1', 9, 7, should_save_result: false )
    result = f.go.result

    r = result.winner_code
    results[r] ||= 0
    results[r] += 1

    lords_surviving_count += result.lords_surviving_count
    au, ru = result.losses_stats
    total_amount_of_units += au
    total_remaining_units += ru
  end

  total = results[ :equality ] + results[ :defender ] + results[ :attacker ]
  equality = ( results[ :equality ].to_f * 100 ) / total
  defender = ( results[ :defender ].to_f * 100 ) / total
  attacker = ( results[ :attacker ].to_f * 100 ) / total
  puts "Attacker win : #{attacker}%, equality : #{equality}%, defender win : #{defender}%"

  survival_rate = ( total_remaining_units.to_f * 100 ) / total_amount_of_units
  puts "All units survival rate : #{survival_rate}%"

  lsr = ( lords_surviving_count.to_f * 100 ) / (runs*2)
  puts "Lords survival rate :#{lsr}%"
end


def one_shot
  c = Fight::Base.new(1, 'O1', 9, 10, verbose: true )
  c.go

  # puts c.combat_log.to_yaml
# pp c.body_count
# pp c.result.attacker_points_list
# pp c.result.winner_code
end

# stats
one_shot



