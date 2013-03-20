require "api_spec_helper"
require 'cancan/matchers'

describe "Connection abilities" do
  context "when user" do
    let(:user) { Factory(:user) }
    let(:contact) { Factory(:user) }
    let(:connection) { contact.be_friends_with(user);
                       user.be_friends_with(contact).first }
    subject { Api::Ability.new(user) }

    it "should be able to manage friendship" do
      subject.should be_able_to :manage, connection
    end
  end

  context "when redu_admin" do
    subject { Api::Ability.new(user) }
    let(:user) { Factory(:user, :role => Role[:admin]) }
    it "should be able to manage all" do
      subject.should be_able_to :manage, :all
    end
  end

  context "when friend" do
    let(:user) { Factory(:user) }
    let(:contact) { Factory(:user) }
    let(:connection) { contact.be_friends_with(user);
                       user.be_friends_with(contact).first }
    subject { Api::Ability.new(contact) }

    it "shold not be able read" do
      subject.should_not be_able_to :read, connection
    end
  end
end
