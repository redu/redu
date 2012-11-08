require 'spec_helper'

describe 'SpacesShowCache' do
  render_views
  let(:user) { Factory(:user) }
  let(:space) { Factory(:space) }

  before do
    @controller = SpacesController.new
    @controller.stub(:current_user) { user }
    sub = Factory(:subject, :space => space, :owner => space.owner,
                 :finalized => true)

    @lecture = Factory(:lecture, :subject => sub,
                      :owner => sub.owner)

    space.course.join(user)
  end

  let(:cache_identifier) do
    "views/space_lecture_item/#{@lecture.id}/#{user.id}"
  end

  context "spaces_lectures_item" do
    context "writing" do
      it "should create a cache" do
        performing_cache do |cache|
          get :show, :id => space.id, :locale => 'pt-BR'
          cache.should exist(cache_identifier)
        end
      end
    end

    context "expiration" do
      it 'expires when lecture is changed' do
        ActiveRecord::Observer.with_observers(:lecture_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            @lecture.name = "New name"
            @lecture.save
            @lecture.subject.members.each do |member|
              cache.should_not \
                exist("views/space_lecture_item/#{@lecture.id}/#{member.id}")
            end
          end
        end
      end

      it "doesn't expire when lecture view count is changed" do
        ActiveRecord::Observer.with_observers(:lecture_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            @lecture.view_count = 10
            @lecture.save
            @lecture.subject.members.each do |member|
              cache.should exist("views/space_lecture_item/#{@lecture.id}/#{member.id}")
            end
          end
        end
      end

      it "expire when lecture change position" do
        ActiveRecord::Observer.with_observers(:lecture_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            @lecture.position = 2
            @lecture.save
            @lecture.subject.members.each do |member|
              cache.should_not \
                exist("views/space_lecture_item/#{@lecture.id}/#{member.id}")
            end
          end
        end
      end

      it 'expire when lecture destroyed' do
        ActiveRecord::Observer.with_observers(:lecture_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            @lecture.destroy
            @lecture.subject.members.each do |member|
              cache.should_not exist("views/space_lecture_item/#{@lecture.id}/#{member.id}")
            end
          end
        end
      end

      it 'expire when asset reports are done' do
        ActiveRecord::Observer.with_observers(:asset_report_cache_observer) do
          performing_cache(cache_identifier) do |cache|
            ar = @lecture.asset_reports.first
            ar.done = true
            ar.save
            cache.should_not exist(cache_identifier)
          end
        end
      end

    end
  end
end
