class MapController < ApplicationController

  # before_action :set_player_for_campaign, only: [:show]

  TMP_FNAME = 'data/map_icons_positions.yaml'

  def show
    @campaign = Campaign.find(params[:campaign_id] )
    @gangs = @campaign.gangs.where.not( gang_destroyed: true ).where.not( retreating: true )
    @map = GameRules::Map.new
  end

  def modify_positions
    @original_map = GameRules::Map.new
    @icons_map = YAML.load_file( TMP_FNAME )
  end

  def create_positions
  end

  def save_position
    location = params[:location]
    position = { x: params[:position][:left], y: params[:position][:top] }
    kind = params[:kind]

    unless File.exist?( TMP_FNAME )
      File.open( TMP_FNAME, 'w') do |f|
        f.write({}.to_yaml)
      end
    end

    letters_map = YAML.load_file( TMP_FNAME )

    letters_map[ location.to_sym ] ||= {}
    letters_map[ location.to_sym ][ kind.to_sym ] = position

    File.open( TMP_FNAME, 'w') do |f|
      f.write( letters_map.to_yaml )
    end

  end

end
