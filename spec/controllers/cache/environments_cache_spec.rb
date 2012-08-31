require 'spec_helper'

describe "EnvironmentsController" do
  render_views
  let(:user) { Factory(:user) }
  let(:environment) { Factory(:environment, :owner => user) }

  before do
    @controller = EnvironmentsController.new
    @controller.stub(:current_user) { user }
  end

  context "show" do
    before do
      @courses = []
      3.times do
        @courses << Factory(:course, :environment => environment,
                           :owner => environment.owner)
      end
      @user2 = Factory(:user)
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
end
