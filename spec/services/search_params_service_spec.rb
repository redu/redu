require 'spec_helper'

describe SearchParamsService do
  let(:params) { { :f => ["ambientes"], :action => "environments" } }

  subject { SearchParamsService.new(params) }

  context "initializing" do
    it "should define filters" do
      subject.filters.should_not be_nil
    end

    it "should define empty filters" do
      service = SearchParamsService.new({  })

      service.filters.should be_empty
    end
  end

  context "methods" do
    it "should be an individual page" do
      subject.individual_page?.should be_true
    end

    it "should not be an individual page" do
      service = SearchParamsService.new({  })

      service.individual_page?.should be_false
    end

    it "should not be preview" do
      subject.preview?.should be_false
    end

    it "should has filter" do
      subject.has_filter?("ambientes").should be_true
    end

    it "should define klasses to search" do
      subject.klasses_for_search.should eq([EnvironmentSearch])
    end
  end
end
