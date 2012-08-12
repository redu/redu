require 'spec_helper'
require 'authlogic/test_case'

describe PartnerUserAssociationsController do
  include Authlogic::TestCase

  context "when listing collaborators from a partner" do
    before do
      @user = Factory(:user)
      activate_authlogic
      UserSession.create @user

      @partner = Factory(:partner)
      environment = Factory(:environment)
      Factory(:partner_environment_association,
              :environment => environment,
              :partner => @partner)
      @partner.add_collaborator(@user)

      get :index, :partner_id => @partner.id, :locale => "pt-BR"
    end

    it "assigns the correct collaborators" do
      assigns[:partner_user_associations].should_not be_nil
      assigns[:partner_user_associations].to_set.should == \
        @partner.partner_user_associations.to_set
    end

    it "loads the partner" do
      assigns[:partner].should_not be_nil
      assigns[:partner].should == @partner
    end

    it "renders the correct template" do
      response.should render_template 'partner_user_associations/index'
    end
  end

end
