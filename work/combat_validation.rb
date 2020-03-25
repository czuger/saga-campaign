require 'active_record'
require 'hazard'
require 'pp'
require 'i18n'

require_relative '../app/models/application_record'
require_relative '../app/models/gang'
require_relative '../app/models/player'
require_relative '../app/models/user'
require_relative '../app/models/unit'
require_relative '../app/models/fight_result'
require_relative '../app/models/game_rules/unit'
require_relative '../app/models/game_rules/'
require_relative '../app/models/game_rules/_attack_atomic_step'
require_relative '../app/models/game_rules/_attack_with_retaliation'
require_relative '../app/models/game_rules/_attack_count_points'

db = YAML.load_file( 'config/database.yml' )['development']
db['pool'] = 5

ActiveRecord::Base.establish_connection(db )

I18n.config.load_path += Dir['config/locales/**/*.{rb,yml,yaml}']

I18n.config.available_locales = [ :fr, :en ]
I18n.default_locale = :fr

def stats
  results = {}
  f = Fight::Base.new(8, 'O1', 2, 1, save_result: false )

  1.upto(500) do |i|
    p i if i % 100 == 0
    r = f.go.result.winner_code
    results[r] ||= 0
    results[r] += 1
  end
  pp results
end


def one_shot
  c = Fight::Base.new(1, 'O1', 11, 10 )
  c.go
# pp c.combat_log
# pp c.body_count
# pp c.result.attacker_points_list
# pp c.result.winner_code
end

# stats
one_shot



