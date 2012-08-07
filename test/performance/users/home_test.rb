require 'performance_test_helper'

class HomeTest < ActionDispatch::PerformanceTest
  def setup
    @user = User.find('julianalucena')
  end

  def test_query_friends
    @user.friends.paginate(:page => 1, :per_page => 9)
  end

  def test_query_friends_requisitions
    @user.friends_pending
  end

  def test_query_course_invitations
    @user.course_invitations
  end

  def test_query_statuses
    @user.home_activity(1)
  end

  def test_query_contacts_recommendations
    @user.recommended_contacts(5)
  end
end
