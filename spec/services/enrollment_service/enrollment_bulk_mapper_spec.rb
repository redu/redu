# -*- encoding : utf-8 -*-
require "spec_helper"

module EnrollmentService

  describe EnrollmentBulkMapper do
    subject { EnrollmentBulkMapper.new }
    let(:records) do
      [ [12, 13, "member"], [14, 15, "teacher"] ]
    end

    it "should create the correct Enrollments quantity" do
      expect {
        subject.insert(records)
      }.to change(Enrollment, :count).by(2)
    end

    it "should not duplicate records" do
      subject.insert(records)

      expect { subject.insert(records) }.to_not change(Enrollment, :count)
    end

    it "should accept a optional columns parameters" do
      records = [[1, :member]]
      columns = [:user_id, :role]

      Enrollment.should_receive(:import).
        with(columns, records, subject.default_options)

      subject.insert(records, columns: columns)
    end
  end
end
