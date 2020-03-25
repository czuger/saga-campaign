require 'test_helper'

class FightResultTest < ActiveSupport::TestCase

  test 'should run a big fight to check for syntax errors' do

    @user = create( :user )
    @campaign = create( :campaign, user: @user )
    @player = create( :player, user: @user, campaign: @campaign )

    hg = create( :horde_gang, campaign: @campaign, player: @player )
    create( :unit_lord_horde, gang: hg )
    create( :unit_sorcerer_horde, gang: hg )
    create( :unit_gardes_horde, gang: hg )
    create( :unit_levees_horde, gang: hg )

    ng = create( :gang, campaign: @campaign, player: @player )
    create( :unit_lord_nature, gang: ng )
    create( :unit_sorcerer_nature, gang: ng )
    create( :unit_gardes_nature, gang: ng )
    create( :unit_guerriers_nature, gang: ng )

    GameRules::Fight.new( @campaign.id, 'O1', hg.id, ng.id ).go
  end

end
