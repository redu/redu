require 'api_spec_helper'

describe Api::ConnectionsController do
  let(:user) { Factory(:user) }
  let(:contact) { Factory(:user) }
  let(:token) { _, _, token = generate_token(user); token }
  let(:params) {{ :oauth_token => token, :format => 'json' }}

  context "GET /connections/:id" do
    before do
      contact.be_friends_with(user)
      connection = user.friendships.first

      get "api/connections/#{connection.id}", params
    end

    context "correct document" do
      it "should return status 200" do
        response.code.should == "200"
      end

      it "should have the correct keys" do
        %w( id status contact user).each do |attr|
          parse(response.body).should have_key attr
        end
      end

      it "should have correct links"  do
        links = parse(response.body)['links']
        links.collect! { |l| l.fetch('rel') }

        %w(self user contact).each do |link|
          links.should include link
        end
      end

      it "should return valid relationships" do
        parse(response.body)['links'].each do |rel|
          get rel['href'], params
          response.code.should == "200"
        end
      end
    end

    it "should return status 404" do
      get "api/connections/212121", params

      response.code.should == "404"
    end
  end

  context "GET /users/:user_id/connections" do
    before do
      contact.be_friends_with(user)
      user.be_friends_with(contact)

      contact_2 = Factory(:user)
      contact_2.be_friends_with(user)
    end

    it "should return status 200" do
      get "/api/users/#{user.id}/connections", params

      response.code.should == "200"
    end

    it "should representer the connections" do
      get "api/users/#{user.id}/connections", params

      parse(response.body).should be_kind_of Array
      parse(response.body).first['user']['first_name'].should == user.first_name
    end

    it "should accept filters" do
      params[:status] = 'accepted'
      get "api/users/#{user.id}/connections", params

      parse(response.body).first['contact']['first_name'].should == \
        contact.first_name
    end
  end
end
