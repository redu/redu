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
    let(:enrollments_attrs) do
      columns = []
      subjects.map do |subj|
        space = subj.space
        space.user_space_associations.each do |uca|
          columns << [uca.user_id, subj.id, uca.role.to_s]
        end
      end
      columns
    end

    subject { CreateEnrollment.new(:subject => subjects) }

    context "#create" do
      it "should delegate to insert with correct arguments" do
        subject.importer.should_receive(:insert).with(enrollments_attrs)

        subject.create
      end

      it "should accept an optional list of [[user, role]]" do
        users = 2.times.collect { Factory(:user) }
        user_role_pairs = users.collect { |u| [u, Role[:member]] }

        records = []
        subjects.each do |s|
          user_role_pairs.each do |(user, role)|
            records << [user.id, s.id, role]
          end
        end

        subject.importer.should_receive(:insert).with(records)

        subject.create(user_role_pairs)
      end
    end
  end
end
