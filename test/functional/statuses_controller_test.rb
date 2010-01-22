require 'test_helper'

class StatusesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:statuses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create status" do
    assert_difference('Status.count') do
      post :create, :status => { }
    end

    assert_redirected_to status_path(assigns(:status))
  end

  test "should show status" do
    get :show, :id => statuses(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => statuses(:one).to_param
    assert_response :success
  end

  test "should update status" do
    put :update, :id => statuses(:one).to_param, :status => { }
    assert_redirected_to status_path(assigns(:status))
  end

  test "should destroy status" do
    assert_difference('Status.count', -1) do
      delete :destroy, :id => statuses(:one).to_param
    end

    assert_redirected_to statuses_path
  end
end
