require 'test_helper'

class Admin::CommentsControllerTest < ActionController::TestCase
  test 'review comments not logged in' do
    xhr :get, :index, :type => 'admin'
    assert_login_required
  end

  test 'review comments unauthorized' do
    login(users(:gg))
    xhr :get, :index, :type => 'admin'
    assert_unauthorized
  end

  test 'review comments' do
    login(users(:admin))
    xhr :get, :index, :type => 'admin'
    assert_response :success
  end
end
