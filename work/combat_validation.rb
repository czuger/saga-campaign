require 'active_record'
require 'hazard'
require 'pp'

require_relative '../app/models/application_record'
require_relative '../app/models/gang'
require_relative '../app/models/player'
require_relative '../app/models/user'
require_relative '../app/models/unit'
require_relative '../app/models/fight_result'
require_relative '../app/models/game_rules/unit'
require_relative '../app/models/game_rules/fight'
require_relative '../app/models/game_rules/fight_attack_atomic_step'
require_relative '../app/models/game_rules/fight_attack_with_retaliation'

db = YAML.load_file( 'config/database.yml' )['development']
db['pool'] = 5

ActiveRecord::Base.establish_connection(db )

# def stats
#   results = {}
#   f = GameRules::Fight.new( true )
#
#   1.upto(5000) do |i|
#     p i if i % 100 == 0
#     r = f.go
#     results[r] ||= 0
#     results[r] += 1
#   end
#   pp results
# end

# stats

c = GameRules::Fight.new( 8, 'O1', 1, 2 )
c.go

pp c.combat_log

pp c.body_count


