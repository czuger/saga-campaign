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

db = YAML.load_file( 'config/database.yml' )['development']
db['pool'] = 5

ActiveRecord::Base.establish_connection(db )

I18n.config.load_path += Dir['config/locales/**/*.{rb,yml,yaml}']

I18n.config.available_locales = [ :fr, :en ]
I18n.default_locale = :fr

def stats
  results = {}
  f = Fight::Base.new(2, 'O1', 2, 1, save_result: false )

  1.upto(500) do |i|
    p i if i % 100 == 0
    r = f.go.result.winner_code
    results[r] ||= 0
    results[r] += 1
  end
  pp results
end


def one_shot
  c = Fight::Base.new(2, 'O1', 2, 1, verbose: true )
  c.go
  # puts c.combat_log.to_yaml
# pp c.body_count
# pp c.result.attacker_points_list
# pp c.result.winner_code
end

# stats
one_shot



