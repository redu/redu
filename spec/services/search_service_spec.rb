# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SearchService do
  let(:params) {{ :q => 'Alex', :f => ["disciplinas"],
                  :action => "environments", :locale => 'pt-BR' }}
  let(:per_page) { 10 }
  let(:user) { FactoryBot.create(:user) }

  subject { SearchService.new(:params => params,
                              :ability => Ability.new(user),
                              :current_user => user) }

  describe ".new" do
    it { should respond_to(:params) }
    it { should respond_to(:user) }
    it { should respond_to :ability }
    it { should respond_to :filters }
    it { should respond_to :results }
  end

  context "perform search" do
    it "should perform search for many classes" do
      klass_method = SpaceSearch.method(:perform)
      SpaceSearch.should_receive(:perform).once do
        klass_method.call(params[:q], per_page)
      end

      subject.perform_results
    end
  end

  context "filters" do
    before do
      my_course = FactoryBot.create(:course)
      course = FactoryBot.create(:course)
      my_course.join(user)

      @spaces = []
      space = FactoryBot.create(:space, :course => course)
      @my_space = FactoryBot.create(:space, :course => my_course)

      @spaces << space
      @spaces << @my_space

      SpaceSearch.stub_chain(:perform, :results).and_return(@spaces)
      subject.perform_results
    end

    it "should not show spaces when user don't have access for it" do
      subject.klass_results("SpaceSearch").first.should \
        == @my_space
    end

    it "should paginate the filters" do
      subject.klass_results("SpaceSearch").should \
        respond_to :page
    end
  end

  describe "#individual_page?" do
    it { subject.individual_page?.should be_true }

    it "should be_false" do
      service = SearchService.new({ :params => {} })

      service.individual_page?.should be_false
    end
  end

  describe "#preview" do
    it { subject.preview?.should be_false }
  end

  describe "#klass_results" do
    before do
      subject.perform_results
    end

    it { subject.klass_results("SpaceSearch".should_not be_nil) }
  end

  describe "#result_paginate" do
    before do
      subject.perform_results
    end

    it { subject.result_paginate.should respond_to(:page) }
  end
end
