require 'spec_helper'

describe InvitationsUtil do

  before {
    @user = Factory(:user)
    @friends = (1..5).collect { Factory(:user) }
    @email = (1..5).collect { |i| "email#{i}@mail.com"}
    @param = {}
  }

  it "requests with set of friends(redu users) should create set of frienship requests" do
    @param['friend_id'] = @friends.collect{ |f| "#{f.id}," }.to_s
    expect {
      InvitationsUtil.process_invites(@param, @user)
    }.should change{ @user.friendships.count}.from(0).to(5)
    Friendship.all.count.should == 10
  end

  it "requests with a set of emails should create a set of invitations" do
    @param['emails'] = @email.collect { |e| "#{e},"}.to_s
    @user.invitations.count.should == 0
    expect {
      InvitationsUtil.process_invites(@param, @user)
    }.should change{ Invitation.all.count }.from(0).to(5)
    @user.invitations.count.should == 5
  end

  it "request with a set of emails and friends (redu users) should create a set of both invites types" do
    @param['emails'] = @email.collect { |e| "#{e},"}.to_s
    @param['friend_id'] = @friends.collect{ |f| "#{f.id}," }.to_s
    expect {
      InvitationsUtil.process_invites(@param, @user)
    }.should change{ Invitation.all.count}.from(0).to(5)
    Friendship.all.count.should == 10
    @user.friendships.count.should == 5
    @user.invitations.count.should == 5
  end

  it "duplicated request" do
    @param['emails'] = ['teste@mail.com, teste@mail.com']
    expect {
      InvitationsUtil.process_invites(@param, @user)
    }.should change{ Invitation.all.count }.from(0).to(1)
  end

  it "when email exists in redu database, a friendship should be created instead of a invitation" do
    @param['emails'] = @email.collect { |e| "#{e},"}.to_s
    @param['emails'] << @user.email
    user = Factory(:user)
    expect {
      InvitationsUtil.process_invites(@param, user)
    }.should change{ Invitation.all.count }.from(0).to(5)
    Friendship.all.count.should == 2
    user.friendships.count.should == 1
  end

  context "Add only one client" do
    it "A friendship request should be correctly sent" do
      requested_user = @friends.first
      @param['friend_id'] = requested_user.id
      expect {
        InvitationsUtil.process_invites(@param, @user)
      }.should change { Invitation.all.count}.by(0)
      @user.friendships.count.should == 1
      requested_user.friendships.count.should == 1
    end
  end
end
