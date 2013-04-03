require 'spec_helper'

describe 'SearchTeacherCache' do
  let(:user) { Factory(:user) }
  let(:course) { Factory(:course) }

  context 'search_course_teachers_count' do
    let(:cache_identifier) { "views/search_course_teachers_count/#{course.id}" }

    context "writing" do
      let(:courses) { [course] }

      before do
        mock_search_perform(courses, CourseSearch)
      end

      it_should_behave_like 'cache writing' do
        let(:controller) { SearchController.new }
        let(:requisition) { get :environments, :f => ['cursos'],
                            :q => 'Makeup', :locale => 'pt-BR' }
      end
    end

    context "expiration" do
      it "expires when teacher user_course_association is created" do
        ActiveRecord::Observer.with_observers(:user_course_association_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            Factory(:user_course_association, :user => user,
                    :course => course, :role => :teacher).approve!

            cache.should_not exist(cache_identifier)
          end
        end
      end

      it "expires when user_course_association role is updated" do
        Factory(:user_course_association, :user => user,
                :course => course, :role => :member).approve!

        ActiveRecord::Observer.with_observers(:user_course_association_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            course.change_role(user, :teacher)

            cache.should_not exist(cache_identifier)
          end
        end
      end

      it "expires when teacher user_course_association is destroyed" do
        Factory(:user_course_association, :user => user,
                :course => course, :role => :teacher).approve!

        ActiveRecord::Observer.with_observers(:user_course_association_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            course.teachers.first.destroy

            cache.should_not exist(cache_identifier)
          end
        end
      end
    end
  end
end
