require 'spec_helper'
require "support/api/oauth"
require "support/api/base"

describe Untied::UserRepresenter do
  include Api::Helpers
  let(:user) do
    Factory(:user).extend(Untied::UserRepresenter)
  end
  let(:user_repr) { parse(user.to_json).fetch('user', {}) }

  context "properties" do
    %w(login first_name last_name id crypted_password password_salt email
       persistence_token client_applications).each do |property|
        it "should have property #{property}" do
          user_repr.should have_key(property)
        end
    end
  end

  context "client_applications" do
    include OAuth::Helpers
    before do
      @application, @current_user, @token = generate_token(user)
    end

    it "should include API token and application" do
      @application.update_attribute(:walledgarden, true)
      tokens = user_repr.fetch("client_applications", [])

      tokens.should == [{
        "name" => @application.name,
        "user_token" => @token,
        "secret" => @application.secret,
        "key" => @application.key
      }]
    end

    it "should not include API token for non walledgarden apps" do
      tokens = user_repr.fetch("client_applications", [])
      tokens.should be_empty
    end
  end

end
