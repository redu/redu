require 'spec_helper'

describe SubjectObserver do
  describe :after_update do
    context "Logger" do
      it "logs the creation" do
        sub = Factory(:subject, :visible => true)
        Factory(:lecture, :subject => sub)

        ActiveRecord::Observer.with_observers(:subject_observer) do
          expect {
            sub.finalized = true
            sub.save
          }.to change(sub.logs, :count).by(1)
        end
      end
    end # context "Logger"

    context "mailer" do
      before do
        UserNotifier.delivery_method = :test
        UserNotifier.perform_deliveries = true
        UserNotifier.deliveries = []

        @sub = Factory(:subject, :visible => true)
        space = Factory(:space, :owner => @sub.owner)
        Factory(:lecture, :subject => @sub, :owner => @sub.owner)
        @sub.enroll(@sub.owner)
      end

      it "notifies creation" do
        ActiveRecord::Observer.with_observers(:subject_observer) do
          expect {
            @sub.finalized = true
            @sub.save
          }.to change(UserNotifier.deliveries, :count).by(1)
        end
      end

      it "should not notify on update" do
        ActiveRecord::Observer.with_observers(:subject_observer) do
          @sub.update_attribute(:finalized, true)
          expect {
            @sub.update_attribute(:name, "Novo nome")
          }.to_not change(UserNotifier.deliveries, :count).by(1)
        end
      end
    end # context "mailer"

    context "when subject is not yet finalized" do
      before do
        @subject = Factory(:subject, :visible => true)
        Factory(:lecture, :subject => @subject)
      end

      it "should create enrollment associations when subject is finalized" do
        ActiveRecord::Observer.with_observers(:subject_observer) do
          expect {
            @subject.finalized = true
            @subject.save
          }.to change(Enrollment, :count)
        end
      end

      it "should call VisClient.notify_delayed when subject is finalized" do

        VisClient.should_receive(:notify_delayed)

        ActiveRecord::Observer.with_observers(:subject_observer) do
          @subject.finalized = true
          @subject.save
        end
      end

      it "shouldn't create enrollment associations when subject isn't finalized" do
        ActiveRecord::Observer.with_observers(:subject_observer) do
          expect {
            # Esse caso testa também a situação de o (valor do) atributo não ser alterado
            @subject.update_attributes(:finalized => false)
          }.to_not change(Enrollment, :count)
        end
      end
    end # context "when subject is not yes finalized"

  end # describe :after_update
end
