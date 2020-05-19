require 'test_helper'

class TranslationsTest < ActionDispatch::IntegrationTest

  def setup
    create_full_campaign

    @campaign.players_choose_faction!
    @campaign.players_first_hire_and_move!
  end

  test 'all units names and weapons should be translated' do
    factions = YAML.load_file( 'data/factions.yaml' )

    factions[ :regular ].each do |faction, units|
      units.each do |unit, weapons|
        weapons.each do |weapon|
          create( :unit, gang: @gang, libe: unit, weapon: weapon )
        end
      end
    end

    get gang_units_url( @gang )

    @response.body.split( "\n" ).each do |line|
      if line =~ /Translation missing/
        puts line
      end
    end

    assert_select 'td', { count: 0, text: /Translation missing/ }
  end

end
