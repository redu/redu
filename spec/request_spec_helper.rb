require 'spec_helper'
require 'capybara/rails'
require 'capybara/rspec'
require 'selenium/webdriver'

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  # Login support
  config.include RequestsHelper

  # Database cleaner
  config.before do
    except_tables = %w(roles privacies)
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
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
