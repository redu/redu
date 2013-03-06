require 'spec_helper'

describe SearchService do
  let(:params) { { :q => 'Alex', :locale => 'pt-BR' } }
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
      klass_method = CourseSearch.method(:perform)
      CourseSearch.should_receive(:perform).once do
        klass_method.call(params[:q], per_page)
      end

      klass_method = EnvironmentSearch.method(:perform)
      EnvironmentSearch.should_receive(:perform).once do
        klass_method.call(params[:q], per_page)
      end

      subject.perform_klasses_results([CourseSearch, EnvironmentSearch],
                                      :preview => false)
    end
  end

  context "make representable for JSON format" do
    # TODO depende da escolha do input no front-end
    xit "should represents results in the correct format" do

    end
  end

  context "filters" do
    before do
      @user = Factory(:user)

      my_course = Factory(:course)
      course = Factory(:course)
      my_course.join(@user)

      @spaces = []
      space = Factory(:space, :course => course)
      @my_space = Factory(:space, :course => my_course)

      @spaces << space
      @spaces << @my_space
    end

    it "should not show spaces when user don't have access for it" do
      subject.filter_and_paginate_my_spaces(@spaces, @user, {}).first.should \
      be(@my_space)
    end

    it "should paginate the filters" do
      subject.filter_and_paginate_my_spaces(@spaces, @user, {}).should respond_to :paginate
    end
  end
end
