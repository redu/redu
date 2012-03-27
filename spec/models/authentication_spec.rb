require 'spec_helper'

describe Authentication do

  before do
    Factory.create(:authentication)
  end

  it { should belong_to(:user) }
  it { should validate_presence_of(:uid) }
  it { should validate_presence_of(:provider) }
  it { should validate_uniqueness_of(:uid).scoped_to(:provider) }

  context "facebook authenticated user with valid fields" do
    context "but there's already an user with given nickname" do
      before do
        Factory.create(:user, :login => 'SomeUserville')
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
      end
      it "should create a valid user" do
        self.build_user(request.env["omniauth.auth"])
        user = User.find_by_username 'SomeUserville1'
        user.should be_valid
      end
    end
  end

  context "facebook user did not authorized Redu" do
    it "should notice the error message" do
    end
  end

end
