require 'yaml'

Rails.application.config.middleware.use OmniAuth::Builder do

  id= File.exist?( 'config/omniauth.yaml' ) ? YAML.load_file( 'config/omniauth.yaml' ) : {}
  provider :discord, id['DISCORD_CLIENT_ID'], id['DISCORD_CLIENT_SECRET']

end