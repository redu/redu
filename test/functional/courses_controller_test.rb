require 'test_helper'

class CoursesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:courses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create course" do
    assert_difference('Course.count') do
      post :create, :course => { }
    end

    assert_redirected_to course_path(assigns(:course))
  end

  test "should show course" do
    get :show, :id => courses(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => courses(:one).to_param
    assert_response :success
  end

  test "should update course" do
    put :update, :id => courses(:one).to_param, :course => { }
    assert_redirected_to course_path(assigns(:course))
  end

  test "should destroy course" do
    assert_difference('Course.count', -1) do
      delete :destroy, :id => courses(:one).to_param
    end

    assert_redirected_to courses_path
  end
end
