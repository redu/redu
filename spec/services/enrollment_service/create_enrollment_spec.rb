require 'spec_helper'

module EnrollmentService
  describe CreateEnrollment do
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

    subject { CreateEnrollment.new(:subject => subjects) }

    context "#create" do
      it "should delegate to import with correct arguments" do
        columns = []
        subjects.map do |subj|
          space = subj.space
          space.user_space_associations.each do |uca|
            columns << [uca.user_id, subj.id, uca.role.to_s]
          end
        end

        subject.importer.should_receive(:import).with(columns)

        subject.create
      end

      it "should create the correct Enrollments quantity" do
        user_count = subjects.map(&:space).map(&:users).count

        expect {
          subject.create
        }.to change(Enrollment, :count).by(user_count)
      end

      it "should accept an optional list of [[user, role]]" do
        users = 2.times.collect { Factory(:user) }
        user_role_pairs = users.collect { |u| [u, Role[:member]] }

        subject.create(user_role_pairs)

        Enrollment.where(:user_id => users.map(&:id)).count.
          should == users.count * subjects.count
      end

      it "should not duplicate records" do
        subject.create

        expect {
          subject.create
        }.to_not change(Enrollment, :count)
      end
    end
  end
end
