require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
  end

  test 'routes' do
    assert_recognizes({:controller => 'users', :action => 'new'}, '/register')
  end

  test 'register' do
    xhr :get, :new
    assert_response :success
    assert assigns(:user)
    assert assigns(:user).new_record?
  end

  test 'create user' do
    assert_difference('User.count', 1) do
      xhr :post, :create,
          :user => {:username => 'foobar', :password => 'foobar',
                    :fullname => 'Foo Bar', :password_confirmation => 'foobar',
                    :email => 'gg@foobar.com', :about => 'Rockstar'}
    end
    assert_equal 'Registered', flash[:notice]

    assert_no_difference('User.count') do
      xhr :post, :create
    end
    assert_equal 'Registration failed', flash[:error]
  end

  test 'edit user not logged in' do
    xhr :get, :edit, :id => @gg
    assert_login_required
    assert !assigns(:user)
  end

  test 'edit' do
    login(@gg)
    xhr :get, :edit, :id => @gg
    assert_response :success
    assert_equal @gg, assigns(:user)
  end

  test 'update user not logged in' do
    xhr :put, :update, :user => {:email => 'foobar@akshi.com'}, :id => @gg
    assert_login_required
    assert !assigns(:user)
  end

  test 'update' do
    login(@gg)
    xhr :put, :update, :user => {:email => 'foobar@akshi.com'}, :id => @gg
    assert_response :success
    @gg.reload
    assert_equal @gg.email, assigns(:user).email
  end

  test 'reset authentication_token' do
    user = User.create!(:username => 'foobar', :password => 'foobar',
                    :password_confirmation => 'foobar',
                    :email => 'foobar@akshi.com', :fullname => 'foobar')
    login(user)
    previous_token = user.authentication_token
    xhr :put, :update, :operation => 'reset_authentication_token',
              :id => user
    assert_response :success
    user.reload
    assert_not_equal user.authentication_token, previous_token
  end

  test 'forgot password' do
    xhr :get, :forgot_password
    assert_response :success
  end

  test 'send reset' do
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      xhr :post, :send_reset, :username_email => @gg.username
    end
    assert_response :success
    assert_equal @gg, assigns(:user)
    reset_email = ActionMailer::Base.deliveries.last
    assert_equal 'Akshi - Password reset instruction', reset_email.subject
    assert_equal @gg.email, reset_email.to[0]
    assert_match Regexp.new("Hi #{@gg.fullname}"), reset_email.encoded
    assert_match Regexp.new(reset_password_user_path(@gg,
                            :reset_password_token => @gg.reset_password_token)),
                            reset_email.encoded
  end

  test 'send reset invalid user' do
    xhr :post, :send_reset, :username_email => 'blah blah'
    assert_response :success
    assert_equal 'User not found', flash[:error]
    assert_nil assigns(:user)
  end

  test 'reset password' do
    @gg.reset_password!
    xhr :get, :reset_password, :id => @gg,
              :reset_password_token => @gg.reset_password_token
    assert_response :success
    assert_equal @gg, assigns(:user)
  end

  test 'update password' do
    @gg.reset_password!
    xhr :put, :update_password, :id => @gg,
        :reset_password_token => @gg.reset_password_token,
        :user => {:password => 'new_password',
                              :password_confirmation => 'new_password'}
    assert_response :success
    assert assigns(:user).authenticate('new_password')
  end

  test 'show user' do
    xhr :get, :show, :id => @gg
    assert assigns(:user)
    assert_equal @gg, assigns(:user)
  end

  test 'show user learning courses' do
    xhr :get, :courses, :id => @gg, :course_type => 'learning'
    assert_equal @gg, assigns(:user)
    assert_array_equal @gg.learning_courses, assigns(:courses), :id
  end

  test 'show user teaching courses' do
    xhr :get, :courses, :id => @gg, :course_type => 'teaching'
    assert_equal @gg, assigns(:user)
    assert_array_equal @gg.teaching_courses.published, assigns(:courses), :id
  end
end
