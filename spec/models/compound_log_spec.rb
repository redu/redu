require 'spec_helper'

describe CompoundLog do
  subject { Factory(:compound_log) }

  it { should have_many :logs }

  context "when deleting compound log" do
    before do
      @log = Factory(:log)
      subject.logs << @log
    end

    it "should delete successfully" do
      subject.destroy.should == subject
    end

    it "should delete all compounded logs" do
      expect {
        subject.destroy
      }.should change(Log, :count).by(-2)
    end
  end

  context "finder" do
    before do
      @compounded_log_friendships = []
      @compounded_log_course = []
      @compounded_log_user = []

      3.times do
        @compounded_log_user << Factory(:compound_log)
        @compounded_log_course << Factory(:compound_log, :logeable_type => Course.to_s)
        @compounded_log_friendships << Factory(:compound_log, :logeable_type => Friendship.to_s )
      end
    end

    it "retrieves compound logs with especified logeable type" do
      CompoundLog.by_logeable_type('Friendship').should == @compounded_log_friendships
      CompoundLog.by_logeable_type('User').should == @compounded_log_user
      CompoundLog.by_logeable_type('User').count.should == 3
    end
  end

  describe :last_compostable do
    before do
      @robert = Factory(:user, :first_name => 'Robert')
      @ned = Factory(:user, :first_name => 'Ned')

      ActiveRecord::Observer.with_observers(:friendship_observer) do
        @robert.be_friends_with(@ned)
        @ned.be_friends_with(@robert)
        p @status = Status.last
      end
    end

    context 'when no have compounds created' do
      it "should be created an new compound log" do
        expect {
          CompoundLog.last_compostable(@status)
        }.should change(CompoundLog, :count).by(1)
      end
    end
  end
end
