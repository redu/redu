require "spec_helper"
require "helpers/api/oauth"

RSpec.configure do |config|
  include Api::Helpers
  include OAuth::Helpers
end
