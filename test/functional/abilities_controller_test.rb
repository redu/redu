require 'test_helper'

class AbilitiesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:abilities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ability" do
    assert_difference('Ability.count') do
      post :create, :ability => { }
    end

    assert_redirected_to ability_path(assigns(:ability))
  end

  test "should show ability" do
    get :show, :id => abilities(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => abilities(:one).to_param
    assert_response :success
  end

  test "should update ability" do
    put :update, :id => abilities(:one).to_param, :ability => { }
    assert_redirected_to ability_path(assigns(:ability))
  end

  test "should destroy ability" do
    assert_difference('Ability.count', -1) do
      delete :destroy, :id => abilities(:one).to_param
    end

    assert_redirected_to abilities_path
  end
end
