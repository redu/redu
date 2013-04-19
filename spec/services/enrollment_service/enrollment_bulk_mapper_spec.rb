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
  end
end
