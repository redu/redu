require 'spec_helper'
require 'capybara/rails'
require 'capybara/rspec'
require 'db/create_standard_partner'
require 'db/create_audiences'

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  # Dados necessários ao teste
  create_standard_partner
  create_audiences

  # Login support
  config.include RequestsHelper

  # Database cleaner
  config.before do
    except_tables = %w(roles privacies audiences)
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation, { :except => except_tables }
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
    # O parceiro CNS é necessário em algumas páginas
    create_standard_partner
  end

  # Removendo dados das tabelas de setup (roles, privacies e audiences) para
  # evitar duplicação nas próximas vezes que a suite for executada.
  config.after(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  # Utiliza o webdriver para o Chrome
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end

  # Configurações do omniauth
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:facebook] = {
    :provider => 'facebook',
    :uid => '1234567',
    :info => {
      :nickname => 'jbloggs',
      :email => 'joe@bloggs.com',
      :name => 'Joe Bloggs',
      :first_name => 'Joe',
      :last_name => 'Bloggs',
      :image => 'http://graph.facebook.com/1234567/picture?type=square',
      :urls => { :Facebook => 'http://www.facebook.com/jbloggs' },
      :location => 'Palo Alto, California',
      :verified => true
    },
    :credentials => {
      :token => 'ABCDEF...',      # OAuth 2.0 access_token, which you may wish to store
      :expires_at => 1321747205,  # when the access token expires (it always will)
      :expires => true            # this will always be true
    },
    :extra => {
      :raw_info => {
        :id => '1234567',
        :name => 'Joe Bloggs',
        :first_name => 'Joe',
        :last_name => 'Bloggs',
        :link => 'http://www.facebook.com/jbloggs',
        :username => 'jbloggs',
        :location => { :id => '123456789', :name => 'Palo Alto, California' },
        :gender => 'male',
        :email => 'joe@bloggs.com',
        :timezone => -8,
        :locale => 'en_US',
        :verified => true,
        :updated_time => '2011-11-11T06:21:03+0000'
      }
    }
  }
end

# OBSERVERS
