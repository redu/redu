module Permit
  module TestCase
    extend ActiveSupport::Concern
    included do
      let(:policy) { double('Permit::Policy') }
      before do
        @@policy = policy
        Permit::Policy.stub(:new).and_return(policy)
        policy.stub(:commit) do |&block|
          block.call(@@policy) if block
        end
      end
    end
  end
end
