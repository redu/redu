require 'test_helper'

class EnvironmentsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:environments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create environment" do
    assert_difference('Environment.count') do
      post :create, :environment => { }
    end

    assert_redirected_to environment_path(assigns(:environment))
  end

  test "should show environment" do
    get :show, :id => environments(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => environments(:one).to_param
    assert_response :success
  end

  test "should update environment" do
    put :update, :id => environments(:one).to_param, :environment => { }
    assert_redirected_to environment_path(assigns(:environment))
  end

  test "should destroy environment" do
    assert_difference('Environment.count', -1) do
      delete :destroy, :id => environments(:one).to_param
    end

    assert_redirected_to environments_path
  end
end
