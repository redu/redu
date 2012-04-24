require "spec_helper"
require "helpers/api/oauth"
require "helpers/api/base"

RSpec.configure do |config|
  include Api::Helpers
  include OAuth::Helpers
end
