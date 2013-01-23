# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'db/create_roles'
require 'db/create_privacies'
require 'paperclip/matchers'
require 'webmock/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # Inclui os matchers do paperclip
  config.include Paperclip::Shoulda::Matchers

  # Inclui o helper para fazer mock da API do scribd
  config.include ScribdSpecHelper

  # Inclui o helper para habilitar a utilização de cache
  # em determinados contextos
  config.include CacheSpecHelper

  # Inclui o helper para o uso de requisição de vis,
  # funciona juntamente com o webmock
  config.include VisSpecHelper

  # Inclui o helper para logar um usuário
  config.include AuthlogicSpecHelper

  # Adiciona os papéis ao BD, pois estes são necessários nos testes.
  create_roles
  create_privacies

  # Desabilita criação de logs nos specs
  ActiveRecord::Observer.disable_observers

  config.before(:each) do
    WebMock.allow_net_connect!
  end
end

