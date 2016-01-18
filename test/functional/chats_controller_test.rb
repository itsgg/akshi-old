require 'test_helper'

class ChatsControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
    @gg.password = @gg.password_confirmation = 'password'
    @gg.save!
    @course = @gg.teaching_courses.last
  end

  test 'index' do
    login(@gg)
    xhr :get, :index, :course_id => @course.id
    assert_response :success
    assert assigns(:chats)
    assert assigns(:course)
    assert_array_equal assigns(:course).chats, assigns(:chats), :id
  end

  test 'index unauthorized' do
    user = User.create!(:username => 'foobar', :fullname => 'Foobar', :password => 'password',
                        :password_confirmation => 'password', :email => 'foobar@akshi.com')
    login(user)
    xhr :get, :index, :course_id => @course.id
    assert_unauthorized
  end

  test 'create chat unauthorized' do
    user = User.create!(:username => 'foobar', :fullname => 'Foobar', :password => 'password',
                        :password_confirmation => 'password', :email => 'foobar@akshi.com')
    login(user)
    xhr :post, :create, :course_id => @course.id, :chat => {:content => 'Hello world' }
    assert_unauthorized
  end

  test 'create chat not loggedin' do
    xhr :post, :create, :course_id => @course.id, :chat => {:content => 'Hello world' }
    assert_login_required
  end

  test 'create chat' do
    login(@gg)
    assert_difference('Chat.count') do
      xhr :post, :create, :course_id => @course.id, :chat => {:content => 'Hello world' }
    end
    # No duplicate
    assert_no_difference('Chat.count') do
      xhr :post, :create, :course_id => @course.id, :chat => {:content => 'Hello world' }
    end
    assert_difference('Chat.count') do
      xhr :post, :create, :course_id => @course.id, :chat => {:content => 'Hello universe' }
    end
  end

end
