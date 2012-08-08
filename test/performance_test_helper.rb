# See http://m.onkey.org/running-rails-performance-tests-on-real-data

ENV["RAILS_ENV"] ||= 'performance'
require File.expand_path('../../config/environment', __FILE__)

require 'test/unit'
require 'active_support/core_ext/kernel/requires'
require 'active_support/test_case'
require 'action_controller/test_case'
require 'action_dispatch/testing/integration'

require 'rails/performance_test_help'

# You may want to turn off caching, if you're trying to improve non-cached rendering speed.
# Just uncomment this line:
# ActionController::Base.perform_caching = false
