require 'spec_helper'

describe Authentication do

  before do
    Factory.create(:authentication) # Necessário para a validação de unicidade
  end

  it { should belong_to(:user) }
  it { should validate_presence_of(:uid) }
  it { should validate_presence_of(:provider) }
  it { should validate_uniqueness_of(:uid).scoped_to(:provider) }

  describe "#parse" do

    context "when state is not a hash" do
      let(:state) { "eita" }

      it "should return nil" do
        Authentication.parse(state).should_not be
      end
    end

    context "when state is a hash" do
      let(:state) { { :json => 'true' }.to_json }

      it "should return a hash" do
        Authentication.parse(state).should be_instance_of(Hash)
      end
    end
  end # describe "#parse"

  describe "#handle_invitation_token" do

    context "when state is a course invitation token" do
      let(:user) { Factory(:user) }
      let(:course) { Factory(:course) }
      let(:invite) do
        Factory(:user_course_invitation, :course => course, :email => user.email)
      end

      before do
        invite.invite!
        @state = { :invitation_token => invite.token }.to_json.to_s
      end

      it "creates UserCourseAssociation" do
        expect {
          Authentication.handle_invitation_token(@state, user)
        }.to change(UserCourseAssociation, :count).by(1)
      end
    end # context "when state is a course invitation token"

    context "when state is a friendship request token" do
      let(:email) { 'newuser@example.com' }
      let(:invitation) do
        Invitation.invite(:user => @host, :hostable => @host,
                          :email => email)
      end

      before do
        @host = Factory(:user)
        state = { :friendship_invitation_token => invitation.token }.to_json
        @user = Factory(:user, :email => email)
        Authentication.handle_invitation_token(state, @user)
      end

      it "should empty invitations 'cause the only one was already accepted" do
        Invitation.all.should be_empty
      end

      it "should create requested friendship for host user" do
        @host.friendships.requested.should_not be_empty
      end

      it "should create pending friendship for requested user" do
        @user.friendships.pending.should_not be_empty
      end
    end # context "when state is a friendship request token"
  end # describe "#handle_invitation_token"

end
