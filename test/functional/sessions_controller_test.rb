require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test 'routes' do
    assert_recognizes({:controller => 'sessions', :action => 'new'}, '/login')
  end

  test 'login' do
    xhr :get, :new
    assert_response :success

    xhr :post, :create, :username => 'gg', :password => 'password'
    assert_response :success
    assert_equal users(:gg), assigns(:user)
    assert_equal flash[:notice], 'Logged in'
    assert_equal session[:current_user], users(:gg).id
  end

  test 'login on case sensitive' do
    user = User.create(:username => "GG", :password => 'akshi123', :password_confirmation => 'akshi123', :email => 'gg@akshitest.com', :fullname => 'Ganesh Gunasegaran')
    xhr :get, :new
    assert_response :success
    xhr :post, :create, :username => 'GG', :password => 'akshi123'
    assert_response :success
    assert_equal user, assigns(:user)
    assert_equal flash[:notice], 'Logged in'
    assert_equal session[:current_user], user.id
  end

  test 'invalid login' do
    xhr :post, :create, :username => 'gg', :password => 'foobar'
    assert_response :success
    assert_equal 'Invalid username/password', flash[:error]
  end

  test 'logout' do
    gg = users(:gg)
    login(gg)
    xhr :delete, :destroy, :id => gg.id
    assert_response :success
    assert_equal 'Logged out', flash[:notice]
    assert session[:current_user].blank?
  end
end
