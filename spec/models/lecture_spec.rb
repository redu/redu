require 'spec_helper'

describe Lecture do
  subject { Factory(:lecture) }

  it { should belong_to :owner }
  it { should belong_to(:lectureable).dependent(:destroy) }

  it { should have_many(:statuses).dependent(:destroy) }
  it { should have_many(:resources).dependent(:destroy) }
  it { should have_many(:favorites).dependent(:destroy) }
  it { should have_many(:logs).dependent(:destroy) }

  it { should have_one(:subject).through(:asset).dependent(:destroy)}
  it { should have_one(:asset).dependent(:destroy)}

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

  context "finders" do
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
      pending "Need seminar Factory as a support" do
        page = Factory(:lecture)
        seminars = (1..2).collect { Factory(:lecture, :lectureable => :seminar ) }

        Lecture.pages.should == [page, subject]
      end
    end

    it "retrieves lectures that are documents" do
      pending "Need document Factory" do
        page = Factory(:lecture)
        documents = (1..2).collect { Factory(:lecture, :lectureable => :document ) }

        Lecture.document.should == documents
      end
    end

    it "retrieves a specified limited number of lectures" do
      lectures = (1..10).collect { Factory(:lecture) }
      Lecture.limited(5).should have(5).items
    end
  end

  it "generates a permalink" do
    APP_URL.should_not be_nil
    subject.permalink.should include(subject.id.to_s)
    subject.permalink.should include(subject.name.parameterize)
  end
end
