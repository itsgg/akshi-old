require 'test_helper'

class SitesControllerTest < ActionController::TestCase
  test 'update not logged in' do
    xhr :put, :update, :id => :first, :site => {:broadcasting => true}
    assert_login_required
  end

  test 'update unauthorized' do
    login(users(:gg))
    xhr :put, :update, :id => :first, :site => {:broadcasting => true}
    assert_unauthorized
  end

  test 'update admin' do
    login(users(:admin))
    xhr :put, :update, :id => :first, :site => {:broadcasting => true}
    assert_response :success
  end
end
