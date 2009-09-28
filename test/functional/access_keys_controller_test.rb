require 'test_helper'

class AccessKeysControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:access_keys)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create access_key" do
    assert_difference('AccessKey.count') do
      post :create, :access_key => { }
    end

    assert_redirected_to access_key_path(assigns(:access_key))
  end

  test "should show access_key" do
    get :show, :id => access_keys(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => access_keys(:one).to_param
    assert_response :success
  end

  test "should update access_key" do
    put :update, :id => access_keys(:one).to_param, :access_key => { }
    assert_redirected_to access_key_path(assigns(:access_key))
  end

  test "should destroy access_key" do
    assert_difference('AccessKey.count', -1) do
      delete :destroy, :id => access_keys(:one).to_param
    end

    assert_redirected_to access_keys_path
  end
end
