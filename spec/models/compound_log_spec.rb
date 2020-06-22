# -*- encoding : utf-8 -*-
require 'spec_helper'

describe CompoundLog do
  subject { FactoryBot.create(:compound_log) }

  it { should have_many :logs }
  it { CompoundLog.should respond_to(:current_compostable).with(2).arguments }
  it { CompoundLog.new.should respond_to(:compound!).with(2).argument }
  it { CompoundLog.new.should respond_to(:expired?).with(1).argument }
  it { CompoundLog.new.should respond_to(:update_compounded_logs_compound_property).with(1).argument }
  it { CompoundLog.new.should respond_to(:notify) }

  context "when deleting compound log" do
    before do
      @log = FactoryBot.create(:log)
      subject.logs << @log
      @log.compound = true
    end

    it "should delete successfully" do
      subject.destroy.should == subject
    end

    it "should not delete compounded logs" do
      expect {
        subject.destroy
      }.to change(Log, :count).by(0)
    end

    it "should change compounded log's compound property to false" do
      compounded_logs = subject.logs
      subject.destroy
      compounded_logs.each do |compounded|
        compounded.compound.should be_false
      end
    end
  end # context "when deleting compound log"

  describe :expired? do
    context "when it's not expired" do
      before do
        subject.compound_visible_at = Time.now
      end

      it "should return false" do
        subject.expired?(24).should be_false
      end
    end

    context "when it's expired" do
      before do
        subject.compound_visible_at = 1.year.ago
      end

      it "should return true" do
        subject.expired?(24).should be_true
      end
    end
  end # describe :expired?

  describe :current_compostable do
    context "when people are getting friends" do
      before do
        @robert = FactoryBot.create(:user, :login => 'robert_baratheon')
        @ned = FactoryBot.create(:user, :login=> 'eddard_stark')
      end

      context "and there aren't compound logs" do
        it "should create a new one" do
          ActiveRecord::Observer.with_observers(:friendship_observer,
                                                :log_observer,
                                                :status_observer) do
            expect {
                @robert.be_friends_with(@ned)
                @ned.be_friends_with(@robert)
            }.to change(CompoundLog, :count).by(2)
            # Um compound para cada statusable(user)
          end
        end
      end # context "and there aren't compound logs"

      context "and a compound log already exists" do
        before do
          @cercei = FactoryBot.create(:user, :login => 'cercei_lannister')

          ActiveRecord::Observer.with_observers(:friendship_observer,
                                                :log_observer,
                                                :status_observer) do
            @robert.be_friends_with(@ned)
            @ned.be_friends_with(@robert)
          end
        end

        it "should include recently created logs" do
          @robert_compound = CompoundLog.where(:statusable_id => @robert.id).last
          ActiveRecord::Observer.with_observers(:friendship_observer,
                                                :log_observer,
                                                :status_observer) do
            expect {
              @robert.be_friends_with(@cercei)
              @cercei.be_friends_with(@robert)
              @robert_compound.reload
            }.to change(@robert_compound.logs, :count).from(1).to(2)
          end
        end

        context "but it's ttl has expired" do
          before do
            @robert_compound = CompoundLog.where(:statusable_id => @robert.id).last
            @robert_compound.compound_visible_at = 2.day.ago
            @robert_compound.save
          end

          it "should create a new compound log for statusable" do
            ActiveRecord::Observer.with_observers(:friendship_observer,
                                                  :log_observer,
                                                  :status_observer) do
              expect {
                @robert.be_friends_with(@cercei)
                @cercei.be_friends_with(@robert)
              }.to change(CompoundLog, :count).by(2)
            end
          end
        end # context "but it's ttl has expired"

        context "and it has the minimum number of logs (3) to being visible" do
          before do
            @tyrion = FactoryBot.create(:user, :login => 'tyrion_lannister')
            @loras = FactoryBot.create(:user, :login => 'loras_tyrel')

            ActiveRecord::Observer.with_observers(:friendship_observer,
                                                  :log_observer,
                                                  :status_observer) do
              @robert.be_friends_with(@cercei)
              @cercei.be_friends_with(@robert)

              @robert.be_friends_with(@tyrion)
              @tyrion.be_friends_with(@robert)

              @robert.be_friends_with(@loras)
              @loras.be_friends_with(@robert)
            end
            @robert_compounds = CompoundLog.where(:statusable_id => @robert.id)
          end

          it "just have one compoundLog" do
            @robert_compounds.count.should == 1
          end

          it "should contain 3 or more logs" do
            @robert_compounds.last.logs.count.should > 3
          end

          it "should be visible" do
            @robert_compounds.last.compound_visible_at.should_not be_nil
            @robert_compounds.last.compound.should be_false
            # exibe na view
          end

          it "should make the logs invisible" do
            @robert_compounds.last.logs.each do |log|
              log.compound.should be_true
            end
          end
        end # context "and it has the minimum number of logs (3) to being visible"
      end # context "and a compound log already exists"
    end # context "when people are getting friends"

    context "when people are enrolling to courses" do
      before do
        @course = FactoryBot.create(:course, :name => "Game of Thrones")
        @pycelle = FactoryBot.create(:user, :login => 'meistre_pycelle')
      end

      context "and there aren't compound logs" do
        it "should create a new one" do
          ActiveRecord::Observer.with_observers(:user_course_association_observer,
                                                :log_observer,
                                                :status_observer) do
            expect {
              @course.join(@pycelle)
            }.to change(CompoundLog, :count).by(1)
          end
        end

        it "should have the log of owner" do
          ActiveRecord::Observer.with_observers(:user_course_association_observer,
                                                :log_observer,
                                                :status_observer) do
            @course.join(@pycelle)
          end

          @course_compounds = CompoundLog.where(:statusable_id => @course.id)
          @course_compound = @course_compounds.last
          @course_compound.logs.count.should == 1
        end
      end # context "and there aren't compound logs"

      context "and a compound log already exists" do
        before do
          ActiveRecord::Observer.with_observers(:user_course_association_observer,
                                                :log_observer,
                                                :status_observer) do
            @course.join(@pycelle)
            @course_compounds = CompoundLog.where(:statusable_id => @course.id)
            @course_compound = @course_compounds.last
          end
        end

        it "should include new log into existing compound log" do
          jaime = FactoryBot.create(:user, :login => "jaime_lannister")
          ActiveRecord::Observer.with_observers(:user_course_association_observer,
                                                :log_observer,
                                                :status_observer) do
            expect {
                @course.join(jaime)
                @course_compound.reload
            }.to change(@course_compound.logs, :count).from(1).to(2)
          end
        end

        context "but it's ttl has expired" do
          before do
            ActiveRecord::Observer.with_observers(:user_course_association_observer,
                                                  :log_observer,
                                                  :status_observer) do
              @course.join(@pycelle)
            end
            @course_compound = CompoundLog.where(:statusable_id => @course.id).last
            @course_compound.compound_visible_at = 2.day.ago
            @course_compound.save
          end

          it "should create a new compound log for statusable" do
            varys = FactoryBot.create(:user, :login => 'spider_varys')
            ActiveRecord::Observer.with_observers(:user_course_association_observer,
                                                  :log_observer,
                                                  :status_observer) do
              expect {
                @course.join(varys)
              }.to change(CompoundLog, :count).by(1)
            end
              CompoundLog.where(:statusable_id => @course.id).count.should == 2
          end
        end # context "but it's ttl has expired"

        context "and it has the minimum number of logs (3) to being visible" do
          before do
            @be_one_dothraki = FactoryBot.create(:course, :name => "Dothraki Lifestyle")
            @users = 3.times.collect { FactoryBot.create(:user) }
            ActiveRecord::Observer.with_observers(:user_course_association_observer,
                                                  :log_observer,
                                                  :status_observer) do
              @users.each { |user| @be_one_dothraki.join(user) }
            end
            @course_compounds = CompoundLog.where(:statusable_id => @be_one_dothraki.id)
          end

          it "just have one compoundLog" do
            @course_compounds.count.should == 1
          end

          it "should contain 3 or more logs" do
            @course_compounds.last.logs.count.should >= 3
          end

          it "should be visible" do
            @course_compounds.last.compound_visible_at.should_not be_nil
            @course_compounds.last.compound.should be_false
            # exibe na view
          end

          it "should make the logs invisible" do
            @course_compounds.last.logs.each do |log|
              log.compound.should be_true
            end
          end
        end # context "and it has the minimum number of logs (3) to being visible"
      end # context "and a compound log already exists"
    end # context "when people are enrolling to courses"
  end # describe :current_compostable
end
