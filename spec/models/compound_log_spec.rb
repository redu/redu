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
      @robert = Factory(:user, :last_name => 'Baratheon')
      @ned = Factory(:user, :last_name => 'Stark')
    end

    context 'when no have compounds created' do

      it "a new compound log should be created" do
        expect {
          ActiveRecord::Observer.with_observers(:friendship_observer) do
            @robert.be_friends_with(@ned)
            @ned.be_friends_with(@robert)
          end
        }.should change(CompoundLog, :count).by(2)
        # One compound for each statusable(user)
      end
    end

    context "when a compound alread exists" do
      before do
        @cercei = Factory(:user, :last_name => 'Lannister')

        ActiveRecord::Observer.with_observers(:friendship_observer) do
          @robert.be_friends_with(@ned)
          @ned.be_friends_with(@robert)
          @cercei.be_friends_with(@robert)
          @robert.be_friends_with(@cercei)
        end
      end

      it "new logs should be included in a compound log" do
      end
    end
  end
end
