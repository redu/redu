require 'spec_helper'

describe SearchService do
  let(:params) {{ :q => 'Alex', :f => ["ambientes"],
                  :action => "environments", :locale => 'pt-BR' }}
  let(:per_page) { 10 }
  let(:user) { Factory(:user) }

  subject { SearchService.new(:params => params,
                              :current_user => user) }

  context "initializing" do
    it "should instantiate params" do
      subject.params.should_not be_nil
    end

    it "should instantiate current user" do
      subject.user.should_not be_nil
    end

    it "should define filters" do
      subject.filters.should_not be_nil
    end

    it "should define empty filters" do
      service = SearchService.new({ :params => {} })

      service.filters.should be_empty
    end
  end

  context "perform search" do
    it "should perform results for an class" do
      klass_method = CourseSearch.method(:perform)
      CourseSearch.should_receive(:perform).once do
        klass_method.call(params[:q], per_page)
      end

      subject.perform_results(CourseSearch, :preview => false)
    end

    it "should perform search for many classes" do
      klass_method = EnvironmentSearch.method(:perform)
      EnvironmentSearch.should_receive(:perform).once do
        klass_method.call(params[:q], per_page)
      end

      subject.perform_klasses_results(:preview => false)
    end
  end

  context "filters" do
    before do
      my_course = Factory(:course)
      course = Factory(:course)
      my_course.join(user)

      @spaces = []
      space = Factory(:space, :course => course)
      @my_space = Factory(:space, :course => my_course)

      @spaces << space
      @spaces << @my_space

      SpaceSearch.stub_chain(:perform, :results).and_return(@spaces)
    end

    it "should not show spaces when user don't have access for it" do
      subject.perform_results(SpaceSearch, { :space_search => true }).first.should \
        == @my_space
    end

    it "should paginate the filters" do
      subject.perform_results(SpaceSearch, { :space_search => true }).should \
        respond_to :paginate
    end
  end

  context "methods" do
    it "should be an individual page" do
      subject.individual_page?.should be_true
    end

    it "should not be an individual page" do
      service = SearchService.new({ :params => {} })

      service.individual_page?.should be_false
    end

    it "should not be preview" do
      subject.preview?.should be_false
    end
  end
end
