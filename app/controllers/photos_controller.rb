# require 'mini_magick'

class PhotosController < ApplicationController

  before_action :set_player
  before_action :set_movements_result

  def new
    @photo = Photo.new
  end

  def create
    Photo.transaction do
      picture_path = params[:photo][:picture].path
      picture_extension = File.extname( params[:photo][:picture].path )

      unless @movements_result.fight_result
        @movements_result.create_fight_result!(
          campaign_id: @player.campaign_id, fight_data: {}, fight_log: {}, location: @movements_result.to )
      end

      new_filename = SecureRandom.uuid + picture_extension
      fight_result = @movements_result.fight_result

      @photo = Photo.create!(
        player: @player, fight_result_id: fight_result.id, comment: params[:comment],
        filename: new_filename)

      new_picture_path = 'public/' + @photo.path
      FileUtils.mkdir_p( new_picture_path )

      new_picture_path += new_filename
      FileUtils.mv( picture_path, new_picture_path )

      image = MiniMagick::Image.open(new_picture_path )
      image.resize '1024x1024>'
      image.write new_picture_path
    end
  end

  private

  def set_movements_result
    @movements_result = MovementsResult.find( params[ :movements_result_id ] )
  end
end
