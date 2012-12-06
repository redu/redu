require 'spec_helper'

describe SearchController do
  let(:params) { { :q => 'Alex', :locale => 'pt-BR' } }

  describe "GET index" do

    it "should instantiate UserSearch" do
      klass_instantiation_method = UserSearch.method(:new)
      UserSearch.should_receive(:new).once do
        klass_instantiation_method.call
      end

      get :index, params
    end

    it "should instantiate EnvironmentSearch" do
      klass_instantiation_method = EnvironmentSearch.method(:new)
      EnvironmentSearch.should_receive(:new).once do
        klass_instantiation_method.call
      end

      get :index, params
    end

    it "should instantiate CourseSearch" do
      klass_instantiation_method = CourseSearch.method(:new)
      CourseSearch.should_receive(:new).once do
        klass_instantiation_method.call
      end

      get :index, params
    end

    it "should instantiate SpaceSearch" do
      klass_instantiation_method = SpaceSearch.method(:new)
      SpaceSearch.should_receive(:new).once do
        klass_instantiation_method.call
      end

      get :index, params
    end
  end

  describe "GET profiles" do

    it "should instantiate UserSearch" do
      klass_instantiation_method = UserSearch.method(:new)
      UserSearch.should_receive(:new).once do
        klass_instantiation_method.call
      end

      get :profiles, params
    end
  end

  describe "GET environments" do

    it "should instantiate EnvironmentSearch" do
      klass_instantiation_method = EnvironmentSearch.method(:new)
      EnvironmentSearch.should_receive(:new).once do
        klass_instantiation_method.call
      end

      get :environments, params
    end

    it "should instantiate CourseSearch" do
      klass_instantiation_method = CourseSearch.method(:new)
      CourseSearch.should_receive(:new).once do
        klass_instantiation_method.call
      end

      get :environments, params
    end

    it "should instantiate SpaceSearch" do
      klass_instantiation_method = SpaceSearch.method(:new)
      SpaceSearch.should_receive(:new).once do
        klass_instantiation_method.call
      end

      get :environments, params
    end
  end

  describe "GET environments_only" do

    it "should instantiate EnvironmentSearch" do
      klass_instantiation_method = EnvironmentSearch.method(:new)
      EnvironmentSearch.should_receive(:new).once do
        klass_instantiation_method.call
      end

      get :environments_only, params
    end
  end

  describe "GET courses_only" do

    it "should instantiate CourseSearch" do
      klass_instantiation_method = CourseSearch.method(:new)
      CourseSearch.should_receive(:new).once do
        klass_instantiation_method.call
      end

      get :courses_only, params
    end
  end

  describe "GET spaces_only" do

    it "should instantiate SpaceSearch" do
      klass_instantiation_method = SpaceSearch.method(:new)
      SpaceSearch.should_receive(:new).once do
        klass_instantiation_method.call
      end

      get :spaces_only, params
    end
  end
end
