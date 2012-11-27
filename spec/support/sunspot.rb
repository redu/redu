#
# Put this in spec/support/
# Will use a sunspot stub session as default in all tests.
#
# To actually test the search you'll need something like:
# describe "something", sunspot: true do
#   ...some tests...
# end
#
# If you do this in your spec helper:
# RSpec.configure do |config|
#   ...
#   config.treat_symbols_as_metadata_keys_with_true_values = true
# end
#
# You can drop the true in the options to describe.
# describe "something", sunspot do
#   ...some tests...
# end

# Stubs search for all specs
Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)

# Rspec hook for enable it on selected tests
RSpec.configure do |config|
  config.before :sunspot => true do
    Sunspot.session = Sunspot.session.original_session
    Sunspot.remove_all!
  end

  config.after :sunspot => true do
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
  end
end

#
# Make sunspot index right away in test environment.
#
module Sunspot
  module Rails
    module Searchable
      module InstanceMethods
        def solr_index
          solr_index!
        end

        def solr_remove_from_index
          solr_remove_from_index!
        end
      end
    end
  end
end

