require 'test_helper'

class CoursesControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
    @math = courses(:math101)
  end

  test 'index' do
    get :index
    assert_response :success
    assert_equal Course.published.count, assigns(:courses).size
    assert_equal Category.count, assigns(:categories).size
  end

  test 'search' do
    get :index, :q => {:name_or_description_cont => 'english'}
    assert_response :success
    assert_equal [courses(:eng101)], assigns(:courses)
  end

  test 'categories' do
    get :index, :category => categories(:english).name
    assert_equal categories(:english).courses, assigns(:courses)
  end

  test 'learn without login' do
    xhr :get, :index, :type => 'learn'
    assert_login_required
  end

  test 'teach without login' do
    xhr :get, :index, :type => 'teach'
    assert_login_required
  end

  test 'learn' do
    login(@gg)
    get :index, :type => 'learn'
    assert_array_equal @gg.learning_courses.published,
                       assigns(:courses),
                       :id
  end

  test 'teach' do
    login(@gg)
    get :index, :type => 'teach'
    assert_equal @gg.teaching_courses, assigns(:courses)
  end

  test 'show' do
    course = courses(:eng101)
    xhr :get, :show, :id => course
    assert_equal course, assigns(:course)
  end

  test 'show unpublished' do
    user = User.create!(:username => 'one', :email => 'one@akshi.com',
                        :fullname => 'User One', :password => 'password',
                        :password_confirmation => 'password')
    login(user)
    course = courses(:math101)
    xhr :get, :show, :id => course
    assert_unauthorized
  end

  test 'show unpublished for admin' do
    login(users(:admin))
    course = courses(:math101)
    xhr :get, :show, :id => course
    assert_response :success
  end

  test 'enroll' do
    user = User.create!(:username => 'one', :email => 'one@akshi.com',
                        :fullname => 'User One', :password => 'password',
                        :password_confirmation => 'password')
    login(user)
    course = courses(:comp101)
    xhr :post, :enroll, :id => course, :user_id => user
    assert_response :success
    assert_equal flash[:notice], 'Enrolled'
    assert user.student?(course)
  end

  test 'enroll invalid voucher' do
    user = User.create!(:username => 'one', :email => 'one@akshi.com',
                        :fullname => 'User One', :password => 'password',
                        :password_confirmation => 'password')
    login(user)
    course = courses(:comp101)
    xhr :post, :enroll_by_voucher, :id => course, :user_id => user
    assert_response :success
    assert_equal flash[:error], 'Invalid voucher code'
    assert !user.student?(course)
  end

  test 'enroll valid voucher' do
    user = User.create!(:username => 'one', :email => 'one@akshi.com',
                        :fullname => 'User One', :password => 'password',
                        :password_confirmation => 'password')
    login(user)
    course = courses(:ruby101)
    xhr :post, :enroll_by_voucher, :id => course, :user_id => user,
                                   :voucher_code => course.vouchers.first.code
    assert_response :success
    assert_equal flash[:notice], 'Enrolled'
    assert user.student?(course)
  end

  test 'enroll unpublished' do
    user = User.create!(:username => 'one', :email => 'one@akshi.com',
                        :fullname => 'User One', :password => 'password',
                        :password_confirmation => 'password')
    login(user)
    course = courses(:math101)
    xhr :post, :enroll, :id => course, :user_id => user
    assert_response :success
    assert_equal flash[:error], 'Course not published'
    assert !user.student?(course)
  end

  test 'enroll not logged in' do
    xhr :post, :enroll, :id => Course.last, :user_id => User.last
    assert_login_required
  end

  test 'dropout' do
    login(@gg)
    course = courses(:comp101)
    assert course.students.include?(@gg)
    xhr :post, :dropout, :id => course, :user_id => @gg
    assert_response :success
    assert_equal flash[:notice], 'Dropped out'
    assert !@gg.student?(course)
  end

  test 'dropout unauthorized' do
    xhr :post, :dropout, :id => Course.last, :user_id => User.last
    assert_login_required
  end

  test 'new not logged in' do
    xhr :get, :new
    assert_login_required
  end

  test 'create not logged in' do
    xhr :post, :create
    assert_login_required
  end

  test 'new' do
    login(@gg)
    xhr :get, :new, :user_id => @gg
    assert_response :success
    assert assigns(:course).new_record?
  end

  test 'create' do
    login(@gg)
    assert_difference 'Course.count', 1 do
      xhr :post, :create, :course => {:name => 'Test',
                                      :description => 'This is a test course',
                                      :category_id => Category.last,
                                      :features => Course::FEATURES},
                          :user_id => @gg
    end
    assert_response :success
    assert_equal 'Test', assigns(:course).name
    assert @gg.teacher?(assigns(:course))
  end

  test 'delete not logged in' do
    xhr :delete, :destroy, :user_id => @gg, :id => Course.last
    assert_login_required
  end

  test 'delete another users' do
    login(@gg)
    course = users(:akshi).teaching_courses.last
    xhr :delete, :destroy, :id => course, :user_id => @gg
    assert_unauthorized
  end

  test 'delete course' do
    login(@gg)
    course = @gg.teaching_courses.last
    assert_difference 'Course.count', -1 do
      xhr :delete, :destroy, :id => course, :user_id => @gg
    end
    assert_response :success
  end

  test 'update not logged in' do
    xhr :put, :update, :user_id => @gg, :id => Course.last, :course => {:name => 'Blah'}
    assert_login_required
  end

  test 'update other users' do
    login(@gg)
    xhr :put, :update, :user_id => @gg, :id => (users(:akshi)).teaching_courses.last,
              :course => {:name => 'Foobar'}
    assert_unauthorized
  end

  test 'update' do
    login(@gg)
    course = @gg.teaching_courses.last
    xhr :put, :update, :user_id => @gg, :id => course, :course => {:name => 'morpheus'}
    assert_response :success
    course.reload
    assert_equal 'morpheus', course.name
  end

  test 'update review status' do
    login(@gg)
    xhr :put, :update, :user_id => @gg, :id => courses(:math101),
                       :course => {:published => '1'}
    assert_response :success
    assert_equal 'review', assigns(:course).status
    xhr :put, :update, :user_id => @gg, :id => courses(:math101),
                       :course => {:published => '0'}
    assert_response :success
    assert_equal 'new', assigns(:course).status
    xhr :put, :update, :user_id => @gg, :id => courses(:eng101),
                       :course => {:published => '1'}
    assert_response :success
    assert_equal 'published', assigns(:course).status
  end

  test 'update invalid attributes' do
    login(@gg)
    course = @gg.teaching_courses.last
    xhr :put, :update, :user_id => @gg, :id => course,
                       :course => {:name => nil}
    assert_response :success
    assert_equal 'Update failed', flash[:error]
    course.reload
    assert_not_nil course.name
  end

  test 'users without login' do
    course = Course.last
    xhr :get, :users, :id => course
    assert_response :success
    assert_equal course, assigns(:course)
    assert_equal course.users, assigns(:users)
  end

  test 'update status not logged in' do
    old_status = @math.status
    xhr :put, :update_status, :id => @math.id, :status => 'publish'
    assert_login_required
    assert_equal old_status, @math.status
  end

  test 'update status unauthorized' do
    login(@gg)
    old_status = @math.status
    xhr :put, :update_status, :id => @math.id, :status => 'publish'
    assert_unauthorized
    assert_equal old_status, @math.status
  end

  test 'update status' do
    login(users(:admin))
    xhr :put, :update_status, :id => @math.id, :status => 'publish'
    assert_response :success
    assert_equal 'published', assigns(:course).status
    xhr :put, :update_status, :id => @math.id, :status => 'reject'
    assert_response :success
    assert_equal 'rejected', assigns(:course).status
  end
end
