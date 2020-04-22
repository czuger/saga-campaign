require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase

  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
  include FactoryBot::Syntax::Methods

  def create_full_campaign
    @user = create( :user )
    @campaign = create( :campaign, user: @user )
    @player = create( :player, user: @user, campaign: @campaign )
    @gang = create( :gang, player: @player, campaign: @campaign )
    @unit = create( :unit, gang: @gang )

    OmniAuth.config.test_mode = true

    @discord_auth_hash =
      {
        :provider => 'discord',
        :uid => @user.uid,
        info: {
          name: 'Foo Bar',
        }
      }

    OmniAuth.config.mock_auth[:discord] = OmniAuth::AuthHash.new    @discord_auth_hash
    post '/auth/discord'
    follow_redirect!
  end
end
