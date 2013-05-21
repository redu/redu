# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "EnvironmentsController" do
  render_views
  let(:user) { FactoryGirl.create(:user) }
  let(:environment) { FactoryGirl.create(:environment, :owner => user) }

  before do
    @controller = EnvironmentsController.new
    @controller.stub(:current_user) { user }
  end

  context "show" do
    before do
      @courses = []
      3.times do
        @courses << FactoryGirl.create(:course, :environment => environment,
                           :owner => environment.owner)
      end
      @user2 = FactoryGirl.create(:user)
      @course = @courses.first
    end

    let(:cache_identifier) { "views/course_members_count/#{@course.id}" }

    it "should cache course members count" do
      performing_cache do |cache|
        get :show, :id => environment.path, :locale => "pt-BR"
        @courses.each do |c|
          cache.should exist("views/course_members_count/#{c.id}")
        end
      end
    end

    it "should expire cache when members are added" do
      performing_cache(cache_identifier) do |cache|
        ActiveRecord::Observer.with_observers(:user_course_association_cache_observer) do
          @course.join(@user2)
          cache.should_not exist(cache_identifier)
        end
      end
    end

    it "should expire cache when members are deleted" do
      @course.join(@user2)
      performing_cache(cache_identifier) do |cache|
        ActiveRecord::Observer.with_observers(:user_course_association_cache_observer) do
          uca = UserCourseAssociation.where(:user_id => @user2.id,
                                      :course_id => @course.id).first
          uca.destroy
          cache.should_not exist(cache_identifier)
        end
      end
    end

    it "should expire cache when role are changed" do
      @course.join(@user2)

      performing_cache(cache_identifier) do |cache|
        ActiveRecord::Observer.with_observers(:user_course_association_cache_observer) do
          uca = UserCourseAssociation.where(:user_id => @user2.id,
                                            :course_id => @course.id).first
          uca.role = Role[:teacher]
          uca.save
          cache.should_not exist(cache_identifier)
        end
      end
    end
  end

  context 'environment_sidebar_connections_with_count' do
    let(:cache_identifier) do
      "views/environment_sidebar_connections_with_count/#{environment.id}"
    end

    context 'writing' do
      #spec/support/shared_examples/cache_writing...
      it_should_behave_like 'cache writing' do
        let(:controller) { EnvironmentsController.new }
        let(:requisition) do
          get :show, :id => environment.to_param, :locale => 'pt-BR'
        end
      end
    end

    context 'expiration' do
      let(:course) { FactoryGirl.create(:course, :environment => environment) }

      it 'when a user starts to be a part of an environment' do
        ActiveRecord::Observer.with_observers(
          :user_environment_association_cache_observer) do
            performing_cache(cache_identifier) do |cache|
              course.join FactoryGirl.create(:user)

              cache.should_not exist(cache_identifier)
            end
        end
      end

      context 'when a user participates on a environment' do
        before do
          course.join user
        end

        it 'expire cache when the user goes out' do
          ActiveRecord::Observer.with_observers(
            :user_environment_association_cache_observer) do
              performing_cache(cache_identifier) do |cache|
                course.unjoin user

                cache.should_not exist(cache_identifier)
              end
          end
        end
      end
    end
  end
end
