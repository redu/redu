require 'spec_helper'

describe AuthenticationsHelper do
  describe :facebook_authentication_path do
  	it "should return facebook authentication url." do
  		helper.facebook_authentication_path.should == "/auth/facebook"
  	end
  end
end
