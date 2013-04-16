require 'spec_helper'

describe EnrollmentService do
  context "with one subject" do
    let(:space) { Factory(:space) }
    let(:usas) do
      2.times.collect { Factory(:user_space_association, :space => space) }
    end
    let(:subj) { Factory(:subject, :space => space) }
    subject { EnrollmentService.new(:subject => subj) }

    context "#create" do
      it "should delegate to import with correct arguments" do
        columns = space.user_space_associations.map { |uca| [uca.user_id, subj.id, uca.role.to_s] }

        Enrollment.should_receive(:import).
          with([:user_id, :subject_id, :role], columns, :validate => false,
               :on_duplicate_key_update => [:user_id, :role])

          subject.create
      end

      it "should create the correct Enrollments quantity" do
        expect {
          subject.create
        }.to change(Enrollment, :count).by(space.user_space_associations.count)
      end
    end
  end

  context "with multiple subjects" do
    let(:spaces) { 2.times.map { Factory(:space) } }
    let(:usas) do
      spaces.map do |space|
        2.times.map { Factory(:user_space_association, :space => space) }
      end.flatten
    end
    let(:subjects) do
      spaces.map do |space|
        2.times.map { Factory(:subject, :space => space) }
      end.flatten
    end

    subject { EnrollmentService.new(:subject => subjects) }

    context "#create" do
      it "should delegate to import with correct arguments" do
        columns = []
        subjects.map do |subj|
          space = subj.space
          space.user_space_associations.each do |uca|
            columns << [uca.user_id, subj.id, uca.role.to_s]
          end
        end

        Enrollment.should_receive(:import).
          with([:user_id, :subject_id, :role], columns, :validate => false,
               :on_duplicate_key_update => [:user_id, :role])

          subject.create
      end

      it "should create the correct Enrollments quantity" do
        user_count = subjects.map(&:space).map(&:users).count

        expect {
          subject.create
        }.to change(Enrollment, :count).by(user_count)
      end
    end
  end
end
