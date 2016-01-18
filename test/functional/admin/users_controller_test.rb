require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
    @admin = users(:admin)
  end

  test 'index not logged in' do
    xhr :get, :index, :type => 'admin'
    assert_login_required
  end

  test 'index unauthorized' do
    login(@gg)
    xhr :get, :index, :type => 'admin'
    assert_unauthorized
  end

  test 'index ' do
    login(@admin)
    xhr :get, :index, :type => 'admin'
    assert_response :success
    assert_array_equal User.all, assigns(:users), :id
  end

  test 'shadow not logged in' do
    xhr :get, :shadow, :id => @gg
    assert_login_required
  end

  test 'shadow unauthorized' do
    login(@gg)
    xhr :get, :shadow, :id => @gg
    assert_unauthorized
  end

  test 'shadow' do
    login(@admin)
    xhr :get, :shadow, :id => @gg
    assert_response :success
    assert_equal session[:current_user], @gg.id
  end

  test 'courses not logged in' do
    xhr :get, :courses, :id => @gg
    assert_login_required
  end

  test 'courses unauthorized' do
    login(@gg)
    xhr :get, :courses, :id => @gg
    assert_unauthorized
  end

  test 'courses' do
    login(@admin)
    xhr :get, :courses, :id => @gg
    assert_response :success
    assert_array_equal Course.published, assigns(:courses), :id
  end

  test 'destroy not logged in' do
    assert_no_difference('User.count') do
      xhr :delete, :destroy, :id => @gg
    end
    assert_login_required
  end

  test 'destroy unauthorized' do
    login(@gg)
    assert_no_difference('User.count') do
      xhr :delete, :destroy, :id => @gg
    end
    assert_unauthorized
  end

  test 'destroy' do
    login(@admin)
    assert_difference('User.count', -1) do
      xhr :delete, :destroy, :id => @gg
    end
    assert_response :success
  end

  test 'update not logged in' do
    xhr :put, :update, :id => @gg, :user => {:blocked => true}
    assert_login_required
  end

  test 'update unauthorized' do
    login(@gg)
    xhr :put, :update, :id => @gg, :user => {:blocked => true}
    assert_unauthorized
  end

  test 'update' do
    login(@admin)
    xhr :put, :update, :id => @gg, :user => {:blocked => true}
    assert_response :success
    assert assigns(:user).blocked?
  end

  test 'enroll not logged in' do
    xhr :put, :enroll, :id => @gg, :course_id => courses(:blah101).id
    assert_login_required
  end

  test 'enroll unauthorized' do
    login(@gg)
    xhr :put, :enroll, :id => @gg, :course_id => courses(:blah101).id
    assert_unauthorized
  end

  test 'enroll' do
    login(@admin)
    xhr :put, :enroll, :id => @gg, :course_id => courses(:blah101).id, :checked =>'true'
    assert_response :success
    assert assigns(:user).student?(courses(:blah101))
  end

end
