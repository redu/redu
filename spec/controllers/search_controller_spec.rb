require 'spec_helper'

describe SearchController do
  let(:params) { { :q => 'Alex', :locale => 'pt-BR' } }

  before do
    @user = Factory(:user)
    controller.stub(:current_user => @user)
  end

  describe "GET index" do
    context "services" do
      before do
        @search_service = SearchService.new(:params => params,
                                            :current_user => @user)
        SearchService.stub!(:new).and_return(@search_service)
      end

      it "should instantiate search service" do
        klass_method = @search_service.method(:perform_klasses_results)
        @search_service.should_receive(:perform_klasses_results) do
          klass_method.call(:preview => true)
        end

        get :index, params
      end
    end

    it "should assign search results" do
      get :index, params

      [:profiles, :environments, :courses, :spaces].each do |result|
        assigns[result].should_not be_nil
      end
    end

    it "should assign total results" do
      get :index, params

      assigns[:total_results].should_not be_nil
    end

    it "should assign query param" do
      get :index, params

      assigns[:query].should_not be_nil
    end
  end

  describe "GET profiles" do
    context "services" do
      before do
        @search_service = SearchService.new(:params => params,
                                            :current_user => @user)
        SearchService.stub!(:new).and_return(@search_service)
      end

      it "should instantiate search service" do
        klass_method = @search_service.method(:perform_results)
        @search_service.should_receive(:perform_results) do
          klass_method.call(UserSearch)
        end

        get :profiles, params
      end
    end

    it "should assigns results" do
      get :profiles, params

      assigns[:profiles].should_not be_nil
    end

    it "should assigns total results" do
      get :profiles, params

      assigns[:total_results].should_not be_nil
    end

    it "should assigns query params" do
      get :profiles, params

      assigns[:query].should_not be_nil
    end
  end

  describe "GET environments" do
    context "services" do
      before do
        @search_service = SearchService.new(:params => params,
                                            :current_user => @user)
        SearchService.stub!(:new).and_return(@search_service)
      end

      it "should instantiate search service" do
        klass_method = @search_service.method(:perform_klasses_results)
        @search_service.should_receive(:perform_klasses_results) do
          klass_method.call(:preview => true)
        end

        get :environments, params
      end
    end

    it "should assigns results" do
      get :environments, params

      [:environments, :courses, :spaces].each do |result|
        assigns[result].should_not be_nil
      end
    end

    it "should assigns total results" do
      get :environments, params

      assigns[:total_results].should_not be_nil
    end

    it "should assigns query params" do
      get :environments, params

      assigns[:query].should_not be_nil
    end

    it "should assigns individual page" do
      get :environments, params

      assigns[:individual_page].should_not be_nil
    end

    it "should assigns entity paginate when is individual page" do
      ind_params = { :q => 'Alex', :locale => 'pt-BR', :f => ['ambientes'] }
      get :environments, ind_params

      assigns[:entity_paginate].should_not be_nil
    end
  end
end
