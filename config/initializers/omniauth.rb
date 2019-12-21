require 'yaml'

Rails.application.config.middleware.use OmniAuth::Builder do

  id= []
  if File.exist? 'config/omniauth.yaml'
    id = YAML.load_file( 'config/omniauth.yaml' )
  end

	provider :discord, id['DISCORD_CLIENT_ID'], id['DISCORD_CLIENT_SECRET']
end