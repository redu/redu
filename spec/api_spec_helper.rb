# -*- encoding : utf-8 -*-
require "spec_helper"
require "support/api/oauth"
require "support/api/base"

RSpec.configure do |config|
  include Api::Helpers
  include OAuth::Helpers
end
