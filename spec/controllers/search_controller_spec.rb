require 'spec_helper'

describe SearchController do
  let(:params) { { :q => 'Alex', :locale => 'pt-BR' } }
  let(:per_page) { 10 }

  before do
    controller.stub(:current_user => Factory(:user))
  end

  describe "GET index" do

    it "should instantiate UserSearch" do
      klass_method = UserSearch.method(:perform)
      UserSearch.should_receive(:perform).once do
        klass_method.call(params[:q], per_page)
      end

      get :index, params
    end

    it "should instantiate EnvironmentSearch" do
      klass_method = EnvironmentSearch.method(:perform)
      EnvironmentSearch.should_receive(:perform).once do
        klass_method.call(params[:q], per_page)
      end

      get :index, params
    end

    it "should instantiate CourseSearch" do
      klass_method = CourseSearch.method(:perform)
      CourseSearch.should_receive(:perform).once do
        klass_method.call(params[:q], per_page)
      end

      get :index, params
    end

    it "should instantiate SpaceSearch" do
      klass_method = SpaceSearch.method(:perform)
      SpaceSearch.should_receive(:perform).once do
        klass_method.call(params[:q], per_page)
      end

      get :index, params
    end
  end

  describe "GET profiles" do

    it "should instantiate UserSearch" do
      klass_method = UserSearch.method(:perform)
      UserSearch.should_receive(:perform).once do
        klass_method.call(params[:q], per_page)
      end

      get :profiles, params
    end
  end

  describe "GET environments" do

    it "should instantiate EnvironmentSearch" do
      klass_method = EnvironmentSearch.method(:perform)
      EnvironmentSearch.should_receive(:perform).once do
        klass_method.call(params[:q], per_page)
      end

      get :environments, params
    end

    it "should instantiate CourseSearch" do
      klass_method = CourseSearch.method(:perform)
      CourseSearch.should_receive(:perform).once do
        klass_method.call(params[:q], per_page)
      end

      get :environments, params
    end

    it "should instantiate SpaceSearch" do
      klass_method = SpaceSearch.method(:perform)
      SpaceSearch.should_receive(:perform).once do
        klass_method.call(params[:q], per_page)
      end

      get :environments, params
    end
  end

  describe "GET environments_only" do

    it "should instantiate EnvironmentSearch" do
      klass_method = EnvironmentSearch.method(:perform)
      EnvironmentSearch.should_receive(:perform).once do
        klass_method.call(params[:q], per_page)
      end

      get :environments_only, params
    end
  end

  describe "GET courses_only" do

    it "should instantiate CourseSearch" do
      klass_method = CourseSearch.method(:perform)
      CourseSearch.should_receive(:perform).once do
        klass_method.call(params[:q], per_page)
      end

      get :courses_only, params
    end
  end

  describe "GET spaces_only" do

    it "should instantiate SpaceSearch" do
      klass_method = SpaceSearch.method(:perform)
      SpaceSearch.should_receive(:perform).once do
        klass_method.call(params[:q], per_page)
      end

      get :spaces_only, params
    end
  end
end
