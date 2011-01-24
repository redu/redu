require 'spec_helper'

describe Lecture do
  subject { Factory(:lecture) }

  it { should belong_to :owner }
  it { should belong_to(:lectureable).dependent(:destroy) }

  it { should have_many(:statuses).dependent(:destroy) }
  it { should have_many(:resources).dependent(:destroy) }
  it { should have_many(:favorites).dependent(:destroy) }
  it { should have_many(:logs).dependent(:destroy) }

  it { should belong_to :subject }

  it { should accept_nested_attributes_for :resources }

  it { should validate_presence_of :name }
  it { should validate_presence_of :description }
  #FIXME Problema de tradução
  xit { should ensure_length_of(:description).is_at_least(30).is_at_most(200)}
  it { should validate_presence_of :lectureable }

  it { should_not allow_mass_assignment_of :owner }
  it { should_not allow_mass_assignment_of :published }
  it { should_not allow_mass_assignment_of :view_count }
  it { should_not allow_mass_assignment_of :removed }
  it { should_not allow_mass_assignment_of :is_clone }

  it "responds to next_for" do
    should respond_to :next_for
  end

  it "responds to previous_for" do
    should respond_to :previous_for
  end

  context "finders" do
    it "retrieves unpublished lectures" do
      lectures = (1..3).collect { Factory(:lecture) }
      subject.published = 1
      lectures[2].published = 1
      subject.save
      lectures[2].save

      Lecture.unpublished.should == [lectures[0], lectures[1]]
    end

    it "retrieves published lectures" do
      lectures = (1..3).collect { Factory(:lecture) }
      subject.published = 1
      lectures[2].published = 1
      subject.save
      lectures[2].save

      Lecture.published.should == [lectures[2], subject]
    end

    it "retrieves lectures that are seminars" do
      pending "Need seminar Factory" do
        seminars = (1..2).collect { Factory(:lecture, :lectureable => Factory(:seminar)) }
        Factory(:lecture)

        Lecture.seminars.should == seminars
      end
    end

    it "retrieves lectures that are interactive classes" do
      pending "Need interactive class Factory" do
        interactive_classes = (1..2).collect { Factory(:lecture, :lectureable => Factory(:interactive_class)) }
        Factory(:lecture)

        Lecture.iclasses.should == interactive_classes
      end
    end

    it "retrieves lectures that are pages" do
        page = Factory(:lecture)
        documents = (1..2).collect { Factory(:lecture, :lectureable => Factory(:document)) }

        Lecture.pages.should == [page]
    end

    it "retrieves lectures that are documents" do
        page = Factory(:lecture)
        documents = (1..2).collect { Factory(:lecture, :lectureable => Factory(:document)) }

        Lecture.documents.should == documents
    end

    it "retrieves a specified limited number of lectures" do
      lectures = (1..10).collect { Factory(:lecture) }
      Lecture.limited(5).should have(5).items
    end

    it "retrieves lectures related to a specified lecture" do
      lecture = Factory(:lecture, :name => "Item com nome")
      lecture2 = Factory(:lecture, :name => "Item")

      Lecture.related_to(lecture2).should == [lecture]
    end
  end

  context "being attended" do
    context "when done" do
      it "retrieves the next lecture and mark the current as done" do
        lectures = (1..3).collect { Factory(:lecture) }
        subject1 = Factory(:subject, :lectures => lectures)

        user = Factory(:user)
        subject1.enroll user

        lectures[0].next_for(user, true).should == lectures[1]
        lectures[0].asset_reports.of_user(user).last.
          should be_done
      end
      it "retrieves the previous lecture and mark the current as done" do
        lectures = (1..3).collect { Factory(:lecture) }
        subject1 = Factory(:subject, :lectures => lectures)

        user = Factory(:user)
        subject1.enroll user

        lectures[1].previous_for(user, true).should == lectures[0]
        lectures[1].asset_reports.of_user(user).last.
          should be_done
      end
    end
    context "when not done" do
      it "retrieves the next lecture" do
        lectures = (1..3).collect { Factory(:lecture) }
        subject1 = Factory(:subject, :lectures => lectures)

        user = Factory(:user)
        subject1.enroll user

        lectures[0].next_for(user).should == lectures[1]
        lectures[0].asset_reports.of_user(user).last.
          should_not be_done
      end
      it "retrieves the previous lecture" do
        lectures = (1..3).collect { Factory(:lecture) }
        subject1 = Factory(:subject, :lectures => lectures)

        user = Factory(:user)
        subject1.enroll user

        lectures[1].previous_for(user).should == lectures[0]
        lectures[1].asset_reports.of_user(user).last.
          should_not be_done
      end
    end

  end

  it "generates a permalink" do
    APP_URL.should_not be_nil
    subject.permalink.should include(subject.id.to_s)
    subject.permalink.should include(subject.name.parameterize)
  end
end
