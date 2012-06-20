require 'spec_helper'
require 'capybara/rails'
require 'capybara/rspec'
require "selenium/webdriver"

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  #Login support
  config.include RequestsHelper

  #Database cleaner
  config.before do
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  ActiveRecord::Observer.enable_observers

  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end
end

# OBSERVERS
