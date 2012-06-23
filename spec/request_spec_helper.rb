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

  ActiveRecord::Observer.enable_observers

  # Utiliza o webdriver para o Chrome
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end
end

# OBSERVERS
