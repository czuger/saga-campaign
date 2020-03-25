class MapController < ApplicationController

  before_action :set_player, only: [:show]

  def show
    @campaign = Campaign.find(params[:campaign_id] )
    @gangs = @campaign.gangs
    @map = GameRules::Map.new
  end

  def modify_positions
    @map = GameRules::Map.new
  end

  def create_positions
  end

  def save_position
    letter = params[:letter]

    session[:letters_numbers] ||= {}
    session[:letters_numbers][letter] ||= 0
    session[:letters_numbers][letter] += 1

    letter_number = session[:letters_numbers][letter]

    letter_code = "#{letter}#{letter_number}"

    tmp_fname = 'tmp/map.yaml'
    unless File.exist?( tmp_fname )
      File.open( tmp_fname, 'w') do |f|
        f.write({}.to_yaml)
      end
    end

    letters_map = YAML.load_file( tmp_fname )

    letters_map[ letter_code ] = { x: params[:x].to_i, y: params[:y].to_i }

    File.open( tmp_fname, 'w') do |f|
      f.write( letters_map.to_yaml )
    end

  end

end
