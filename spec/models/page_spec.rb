require 'spec_helper'

describe Page do
  before do
    @page = Factory(:page)
  end

  it { should have_one(:lecture)}
  it { should validate_presence_of(:body)}

  context "finders" do
    it "retrieves one lecture" do
      pending do
        @page.lecture = mock("Lecture", :class => Lecture)
        @page.lecture.should be_kind_of(Lecture)
      end
    end
  end

end
