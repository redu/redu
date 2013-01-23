require 'spec_helper'

describe Quota do
  subject { Factory(:quota) }

  it { should belong_to(:billable) }

  context "when updating quotas" do

    it "responds to update_for" do
      should respond_to(:refresh!)
    end

    context "updates quotas successfully" do
      before do
        @environment = Factory(:environment)
        @courses = (1..3).collect do
          c = Factory(:course, :environment => @environment)
          (1..3).each { Factory(:space, :course => c) }
          c.reload
        end
        @environment.reload
      end

      def create_uploadable_objects_in(spaces)
          files = spaces.collect do |s|
            Factory(:myfile, :folder => s.folders.first,
                    :attachment_file_size => 2.megabytes)
          end

          seminars = spaces.collect do |s|
            sub = Factory(:subject, :space => s, :finalized => true)

            (1..3).collect do
              seminar = Factory(:seminar_upload,
                                :original_file_size => 3.megabytes)
              Factory(:lecture, :subject => sub, :lectureable => seminar)
              seminar
            end
          end
          seminars.flatten!
          mock_scribd_api

          documents = spaces.collect do |s|
            sub = Factory(:subject, :space => s, :finalized => true)

            (1..3).collect do
              doc = Factory(:document, :attachment_file_size => 1.megabytes)
              Factory(:lecture, :subject => sub, :lectureable => doc)
              doc
            end
          end
          documents.flatten!

          spaces.collect do |s|
            sub = Factory(:subject, :space => s)

            seminar = Factory(:seminar_upload,
                              :original_file_size => 3.megabytes)
            doc = Factory(:document, :attachment_file_size => 1.megabytes)

            Factory(:lecture, :subject => sub, :lectureable => seminar)
            Factory(:lecture, :subject => sub, :lectureable => doc)
          end

          { :files => files.collect(&:attachment_file_size).sum,
            :seminars => seminars.collect(&:original_file_size).sum,
            :documents => documents.collect(&:attachment_file_size).sum }
      end

      context "when billable is a course" do
        let(:subject) { Factory(:unused_quota, :billable => @courses.first) }

        before do
          @spaces = @courses.first.spaces

          sizes = create_uploadable_objects_in(@spaces)

          @updated_files_size = sizes[:files]
          @updated_seminars_size = sizes[:seminars]
          @updated_documents_size = sizes[:documents]
        end

        it "should calculate uploaded files size" do
          subject.calculate_files_size(@courses.first).
            should == @updated_files_size
        end

        it "should calculate uploaded seminars size" do
          subject.calculate_seminars_size(@courses.first).
            should == @updated_seminars_size
        end

        it "should calculate uploaded documents size" do
          subject.calculate_documents_size(@courses.first).
            should == @updated_documents_size
        end

        it "should update multimedia files value" do
          expect {
            subject.refresh!
          }.should change { subject.multimedia }.from(0).to(@updated_seminars_size)
        end

        it "should update quota files value" do
          total_files_size = @updated_files_size + @updated_documents_size
          expect {
            subject.refresh!
          }.should change { subject.files }.from(0).to(total_files_size)
        end

      end

      context "when billable is a environment" do
        let(:subject) { Factory(:unused_quota, :billable => @environment) }

        before do
          @courses = @environment.courses
          @spaces = @courses.collect(&:spaces).flatten

          sizes = create_uploadable_objects_in(@spaces)

          @updated_files_size = sizes[:files]
          @updated_seminars_size = sizes[:seminars]
          @updated_documents_size = sizes[:documents]
        end

        it "should calculate uploaded files size" do
          subject.calculate_files_size(@courses).
            should == @updated_files_size
        end

        it "should calculate uploaded seminars size" do
          subject.calculate_seminars_size(@courses).
            should == @updated_seminars_size
        end

        it "should calculate uploaded documents size" do
          subject.calculate_documents_size(@courses).
            should == @updated_documents_size
        end

        it "should update multimedia files value" do
          expect {
            subject.refresh!
          }.should change { subject.multimedia }.from(0).to(@updated_seminars_size)
        end

        it "should update quota files value" do
          total_files_size = @updated_files_size + @updated_documents_size
          expect {
            subject.refresh!
          }.should change { subject.files }.from(0).to(total_files_size)
        end

      end
    end
  end
end
