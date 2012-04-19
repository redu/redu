require 'spec_helper'

describe CompoundLog do
  subject { Factory(:compound_log) }

  it { should have_many :logs }
  it { CompoundLog.should respond_to(:current_compostable).with(2).arguments }
  it { CompoundLog.new.should respond_to(:compound!).with(1).argument }

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
        @compounded_log_course << Factory(:compound_log,
                                          :logeable_type => Course.to_s)
        @compounded_log_friendships << Factory(:compound_log,
                                               :logeable_type => Friendship.to_s )
      end
    end

    it "retrieves compound logs with especified logeable type" do
      CompoundLog.by_logeable_type('Friendship').should == @compounded_log_friendships
      CompoundLog.by_logeable_type('User').should == @compounded_log_user
      CompoundLog.by_logeable_type('User').count.should == 3
    end
  end

  describe :current_compostable do
    before do
      @robert = Factory(:user, :login => 'robert_baratheon')
      @ned = Factory(:user, :login=> 'eddard_stark')
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

    context "when a compound already exists" do
      before do
        @cercei = Factory(:user, :login => 'cercei_lannister')

        ActiveRecord::Observer.with_observers(:friendship_observer) do
          @robert.be_friends_with(@ned)
          @ned.be_friends_with(@robert)
        end
      end

      it "new logs should be included in a compound log" do
        @robert_compound = CompoundLog.by_statusable('User', @robert.id).last
        expect {
          ActiveRecord::Observer.with_observers(:friendship_observer) do
            @robert.be_friends_with(@cercei)
            @cercei.be_friends_with(@robert)
            @robert_compound.reload
          end
        }.should change(@robert_compound.logs, :count).from(1).to(2)
      end

      context "current compostable ttl has expired" do
        before do
          @robert_compound = CompoundLog.by_statusable('User', @robert.id).last
          @robert_compound.compound_visible_at = 2.day.ago
          @robert_compound.save
        end

        it "an new compound should be created for statusable" do
          expect {
            ActiveRecord::Observer.with_observers(:friendship_observer) do
              @robert.be_friends_with(@cercei)
              @cercei.be_friends_with(@robert)
            end
          }.should change(CompoundLog, :count).by(2)
          CompoundLog.by_statusable('User', @robert.id).count.should == 2
          CompoundLog.by_statusable('User', @cercei.id).count.should == 1
        end
      end

      context "when compound group 4 logs" do
        before do
          @tyrion = Factory(:user, :login => 'tyrion_lannister')
          @jhon = Factory(:user, :login => 'jhon_arryn')
          @loras = Factory(:user, :login => 'loras_tyrel')

          ActiveRecord::Observer.with_observers(:friendship_observer) do
            @robert.be_friends_with(@cercei)
            @cercei.be_friends_with(@robert)

            @robert.be_friends_with(@tyrion)
            @tyrion.be_friends_with(@robert)

            @robert.be_friends_with(@jhon)
            @jhon.be_friends_with(@robert)

            @robert.be_friends_with(@loras)
            @loras.be_friends_with(@robert)
          end
          @robert_compounds = CompoundLog.by_statusable('User', @robert.id)
        end

        it "just have one compoundLog" do
          @robert_compounds.count.should == 1
        end

        it "contains 5 or more logs" do
          @robert_compounds.last.logs.count.should > 4
        end

        it "should be visible" do
          @robert_compounds.last.compound_visible_at.should_not be_nil
          @robert_compounds.last.compound.should be_false
          # display on view
        end
      end
    end
  end
end
