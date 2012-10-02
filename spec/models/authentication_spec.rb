require 'spec_helper'

describe Authentication do

  before do
    Factory.create(:authentication) # Necessário para a validação de unicidade
  end

  it { should belong_to(:user) }
  it { should validate_presence_of(:uid) }
  it { should validate_presence_of(:provider) }
  it { should validate_uniqueness_of(:uid).scoped_to(:provider) }

  describe :build_user do

    context "when facebook authenticated user with valid fields" do
      before { @omniauth = OmniAuth.config.mock_auth[:facebook] }

      context "and user nickname has points" do
        before { @omniauth[:info][:nickname] = "nick.with.points" }

        it "should generate a valid login" do
          Authentication.create_user(@omniauth).should be_valid
        end
      end

      context "but there's already an user with given nickname" do
        before { Factory.create(:user, :login => 'SomeUserville') }
        
        it "should return a valid user" do
          Authentication.create_user(@omniauth).should be_valid
        end

        context "and the most obvious nickname is taken too" do
          before { Factory.create(:user, :login => 'SomeUserville1') }

          it "should return a valid user" do
            Authentication.create_user(@omniauth).should be_valid
          end
        end
      end
    end
  end

end
