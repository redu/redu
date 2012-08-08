require 'performance_test_helper'
require 'ruby-debug'

class EnvironmentShowTest < ActionDispatch::PerformanceTest
  def setup
    ApplicationController.class_eval do
      def current_user
        return @current_user if defined?(@current_user)
        @current_user = User.find('guiocavalcanti')
      end
    end

    ApplicationController.new.send(:current_user)
  end

  # Testando envrionment#show com o curso de ciência da computação
  # path: /ium
  def test_environment_show
    get '/ium'
  end
end
