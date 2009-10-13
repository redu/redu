require 'test_helper'

class ExamsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:exams)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create exam" do
    assert_difference('Exam.count') do
      post :create, :exam => { }
    end

    assert_redirected_to exam_path(assigns(:exam))
  end

  test "should show exam" do
    get :show, :id => exams(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => exams(:one).to_param
    assert_response :success
  end

  test "should update exam" do
    put :update, :id => exams(:one).to_param, :exam => { }
    assert_redirected_to exam_path(assigns(:exam))
  end

  test "should destroy exam" do
    assert_difference('Exam.count', -1) do
      delete :destroy, :id => exams(:one).to_param
    end

    assert_redirected_to exams_path
  end
end
