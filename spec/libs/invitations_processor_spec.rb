# -*- encoding : utf-8 -*-
require 'spec_helper'

describe InvitationsProcessor do

  subject do
    class Bar
      include InvitationsProcessor
    end
    Bar.new
  end

  before {
    @user = FactoryGirl.create(:user)
    @friends = (1..5).collect { FactoryGirl.create(:user) }
    @email = (1..@friends.count).collect { |i| "email#{i}@mail.com"}
    @param = {}
  }

  it "requests with set of friends(redu users) should create set of frienship requests" do
    @param['friend_id'] = @friends.map(&:id).join(",")
    expect {
      subject.process_invites(@param, @user)
    }.to change{ @user.friendships.count }.by(5)
    Friendship.all.count.should == 10
  end

  it "requests with a set of emails should create a set of invitations" do
    @param['emails'] = @email.join(",")
    @user.invitations.count.should == 0
    expect {
      subject.process_invites(@param, @user)
    }.to change(Invitation, :count).by(5)
    @user.invitations.count.should == 5
  end

  it "request with a set of emails and friends (redu users) should create a set of both invites types" do
    @param['emails'] = @email.join(",")
    @param['friend_id'] = @friends.map(&:id).join(",")
    expect {
      subject.process_invites(@param, @user)
    }.to change{ Invitation.all.count}.from(0).to(5)
    Friendship.all.count.should == 10
    @user.friendships.count.should == 5
    @user.invitations.count.should == 5
  end

  it "request with duplicated email in params should create only one invitation" do
    @param['emails'] = ['teste@mail.com, teste@mail.com']
    expect {
      subject.process_invites(@param, @user)
    }.to change(Invitation, :count).by(1)
  end

  it "when email exists in redu database, a friendship should be created instead of a invitation" do
    @param['emails'] = @email.join(",")
    @param['emails'] << ",#{@user.email}"
    user = FactoryGirl.create(:user)
    expect {
      subject.process_invites(@param, user)
    }.to change(Invitation, :count).by(5)
    Friendship.all.count.should == 2
    user.friendships.count.should == 1
  end

  context "when a friendship request is sent and expect return" do

    it "An friendship request, should be correctly sent and the friend instance invited should be returned." do
      requested_user = @friends.first
      @param['friend_id'] = requested_user.id
      expect {
        subject.process_invites(@param, @user)
      }.to change(Invitation, :count).by(0)
      @user.friendships.count.should == 1
      requested_user.friendships.count.should == 1
    end
  end

  context "Destroy invitation in batch" do
    before do
      @param['friend_id'] = @friends.map(&:id).join(",")
      @param['emails'] = @email.join(",")
      subject.process_invites(@param, @user)

      @invitations = @user.invitations
      @friendship_requests = @user.friendships.requested
    end

    it "Destroy all friendship requests" do
      expect {
        subject.batch_destroy_friendships(@friendship_requests, @user)
      }.to change(Friendship, :count).by(@friendship_requests.count*-2)
    end

    it "Destroy all invitations" do
      expect{
        subject.batch_destroy_invitations(@invitations, @user)
      }.to change(Invitation, :count).by(@invitations.count*-1)
    end
  end
end
