require 'test_helper'

class Admin::CoursesControllerTest < ActionController::TestCase
  test 'review courses not logged in' do
    xhr :get, :index, :type => 'admin'
    assert_login_required
  end

  test 'review courses unauthorized' do
    login(users(:gg))
    xhr :get, :index, :type => 'admin'
    assert_unauthorized
  end

  test 'review courses' do
    login(users(:admin))
    xhr :get, :index, :type => 'admin'
    assert_response :success
  end
end
