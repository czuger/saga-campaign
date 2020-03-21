require 'active_record'
require 'hazard'

require_relative '../app/models/application_record'
require_relative '../app/models/gang'
require_relative '../app/models/game_rules/unit'
require_relative '../app/models/unit'
require_relative '../app/models/game_rules/fight'

db = YAML.load_file( 'config/database.yml' )['development']
db['pool'] = 5

ActiveRecord::Base.establish_connection(db )

def stats
  results = {}
  f = GameRules::Fight.new( true )
  1.upto(200) do
    r = f.go
    results[r] ||= 0
    results[r] += 1
  end
  pp results
end

# stats

GameRules::Fight.new.go


