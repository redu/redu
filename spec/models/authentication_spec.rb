require 'spec_helper'

describe Authentication do

  before do
    Factory.create(:authentication)
  end

  it { should belong_to(:user) }
  it { should validate_presence_of(:uid) }
  it { should validate_presence_of(:provider) }
  it { should validate_uniqueness_of(:uid).scoped_to(:provider) }

  describe :build_user do

    context "when facebook authenticated user with valid fields" do
      before { @omniauth = OmniAuth.config.mock_auth[:facebook] }

      context "but there's already an user with given nickname" do
        before { Factory.create(:user, :login => 'SomeUserville') }
        
        it "should return a valid user" do
          Authentication.build_user(@omniauth).should be_valid
        end

        context "and the most obvious nickname is taken too" do
          before { Factory.create(:user, :login => 'SomeUserville1') }

          it "should return a valid user" do
            Authentication.build_user(@omniauth).should be_valid
          end
        end
      end
    end
  end

end
