require 'spec_helper'

describe Page do
  before do
    @page = Factory(:page)
  end

  context "associations" do
   it "has one lecture" do
     @page.should respond_to(:lecture)
   end
  end

  context "validations" do
    it "must have a body" do
      @page = Factory.build(:page, :body => '')
      @page.should_not be_valid
      @page.errors.on(:body).should_not be_nil
    end
  end

  context "finders" do
    it "retrieves one lecture" do
      pending do
        @page.lecture = mock("Lecture", :class => Lecture)
        @page.lecture.should be_kind_of(Lecture)
      end
    end
  end

end
