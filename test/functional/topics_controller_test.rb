require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
    @course = courses(:math101)
  end

  test 'New topic without login' do
    xhr :get, :new, :course_id => @course
    assert_login_required
  end

  test 'show not logged in' do
    topic = @course.topics.first
    xhr :get, :show, :course_id => @course, :id => topic
    assert_login_required
  end

  test 'show unauthorized' do
    user = User.create!(:username => 'foobar', :fullname => 'Foobar',
                        :password => 'password',
                        :password_confirmation => 'password',
                        :email => 'foobar@akshi.com')
    login(user)
    topic = @course.topics.first
    xhr :get, :show, :course_id => @course, :id => topic
    assert_unauthorized
  end

  test 'show' do
    login(@gg)
    topic = @course.topics.first
    assert topic.unread?(@gg)
    xhr :get, :show, :course_id => @course, :id => topic
    assert_response :success
    assert !topic.unread?(@gg)
    assert assigns(:topic)
    assert_equal topic, assigns(:topic)
  end

  test 'show feature disabled' do
    login(@gg)
    @course.features = ['announcement']
    assert @course.save
    topic = @course.topics.first
    xhr :get, :show, :course_id => @course, :id => topic
    assert_unauthorized
  end

  test 'New topic' do
    login(@gg)
    xhr :get, :new, :course_id => @course
    assert_response :success
    assert assigns(:topic)
    assert assigns(:topic).new_record?
  end

  test 'search' do
    login(@gg)
    xhr :get, :index, :q => {:content_cont => 'topic two'},
              :course_id => courses(:math101)
    assert_response :success
    assert_equal [topics(:two)], assigns(:topics)
  end

  test 'Create topic without login' do
    xhr :post, :create, :course_id => @course,
        :topic => {:content => 'heal the world'}
    assert_login_required
  end

  test 'Create topic' do
    login(@gg)
    assert_difference('Topic.count', 1) do
      xhr :post, :create, :course_id => @course,
          :topic => {:title => 'carless', :content => 'carless whisper'}
    end
    assert_response :success
    topic = assigns(:topic)
    assert topic
    assert @course.topics.include?(topic)
    assert_equal 'carless whisper', topic.content
    assert_equal 'Created', flash[:notice]
  end

  test 'Create reply' do
    login(@gg)
    assert_difference('Topic.count', 1) do
      xhr :post, :create, :course_id => @course,
          :topic => {:content => 'carless whisper'},
          :parent_id => topics(:one)
    end
    assert_response :success
    assert assigns(:topic)
  end

  test 'Index without login' do
    xhr :get, :index, :course_id => @course
    assert_login_required
  end

  test 'Index' do
    login(@gg)
    topic = @course.topics.last
    assert topic.unread?(@gg)
    xhr :get, :index, :course_id => @course
    topic = assigns(:topic)
    topics = assigns(:topics)
    assert !topic.unread?(@gg)
    assert_equal @course.topics.first, topic
    assert_array_equal @course.topics.top, topics, :id
    assert assigns(:replies)
  end

  test 'index unauthorized' do
    user = User.create!(:username => 'foobar', :fullname => 'Foobar',
                        :password => 'password',
                        :password_confirmation => 'password',
                        :email => 'foobar@akshi.com')
    login(user)
    xhr :get, :index, :course_id => @course
    assert_unauthorized
  end

  test 'delete without login' do
    xhr :delete, :destroy, :course_id => @course, :id => @course.topics.last
    assert_login_required
  end

  test 'delete other users topic' do
    login(@gg)
    akshi = users(:akshi)
    topic = akshi.topics.last
    course = topic.course
    xhr :delete, :destroy, :course_id => course, :id => topic
    assert_unauthorized
  end

  test 'student should not be able to delete topic' do
    login(@gg)
    topic = topics(:five)
    course = topic.course
    xhr :delete, :destroy, :course_id => course, :id => topic
    assert_unauthorized
  end

  test 'teacher delete topic' do
    login(@gg)
    course = @gg.teaching_courses.last
    topic = course.topics.last
    assert_difference('Topic.count', -1) do
      xhr :delete, :destroy, :course_id => course, :id => topic
    end
    assert_equal 'Deleted', flash[:notice]
  end

  test 'edit without login' do
    xhr :get, :edit, :course_id => @course, :id => @course.topics.last
    assert_login_required
  end

  test 'edit other user topic' do
    login(@gg)
    akshi = users(:akshi)
    topic = akshi.topics.last
    course = topic.course
    xhr :get, :edit, :course_id => course, :id => topic
    assert_unauthorized
  end

  test 'edit' do
    login(@gg)
    topic = @gg.topics.last
    course = topic.course
    xhr :get, :edit, :course_id => course, :id => topic
    assert assigns(:topic)
    assert_equal topic, assigns(:topic)
  end

  test 'update without login' do
    xhr :put, :update, :course_id => @course, :id => @course.topics.last,
        :topic => {:content => 'New content'}
    assert_login_required
  end

  test 'update other user topic' do
    login(@gg)
    akshi = users(:akshi)
    topic = akshi.topics.last
    course = topic.course
    xhr :put, :update, :course_id => course, :id => topic,
        :topic => {:content => 'New content'}
    assert_unauthorized
  end

  test 'update' do
    login(@gg)
    topic = @gg.topics.last
    course = topic.course
    xhr :put, :update, :course_id => course, :id => topic,
        :topic => {:title => 'New topic', :content => 'New content'}
    assert_equal 'Updated', flash[:notice]
    assert assigns(:topic)
    assert_equal 'New content', assigns(:topic).content
  end

end
