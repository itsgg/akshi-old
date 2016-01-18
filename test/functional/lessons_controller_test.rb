require 'test_helper'

class LessonsControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
    @course = @gg.teaching_courses.last
  end

  test 'new unauthorized' do
    xhr :get, :new, :course_id => @course
    assert_login_required
    login(@gg)
    xhr :get, :new, :course_id => @gg.learning_courses.last
    assert_unauthorized
  end

  test 'login with authentication_token' do
    gg = users(:gg)
    gg.reset_authentication_token
    xhr :get, :new, :course_id => @course, :token => gg.authentication_token
    assert_response :success
  end

  test 'search' do
    login(@gg)
    xhr :get, :index, :q => {:name_cont => 'statistics'}, :course_id => courses(:math101)
    assert_response :success
    assert_equal [lessons(:statistics)], assigns(:lessons)
  end

  test 'index' do
    course = courses(:math101)
    login(@gg)
    lesson = course.lessons.last
    assert lesson.unread?(@gg)
    xhr :get, :index, :course_id => course
    assert_response :success
    assert assigns(:lesson)
    assert assigns(:lessons)
    assert assigns(:course)
    assert !lesson.unread?(@gg)
    assert_equal course.lessons.first, assigns(:lesson)
  end

  test 'new' do
    login(@gg)
    xhr :get, :new, :course_id => @course
    assert_response :success
    assert assigns(:lesson)
    assert assigns(:lesson).new_record?
  end

  test 'new feature disabled' do
    login(@gg)
    @course.features = ['announcement']
    assert @course.save
    xhr :get, :new, :course_id => @course
    assert_unauthorized
  end

  test 'create unauthorized' do
    assert_no_difference('Lesson.count') do
      xhr :post, :create, :course_id => @course, :lesson => {:name => 'blah'}
    end
    assert_login_required
    login(@gg)
    assert_no_difference('Lesson.count') do
      xhr :post, :create, :course_id => @gg.learning_courses.last,
                 :lesson => {:name => 'blah'}
    end
    assert_unauthorized
  end

  test 'create' do
    login(@gg)
    assert_difference('Lesson.count', 1) do
      xhr :post, :create, :course_id => @course, :lesson => {:name => 'hello one'}
    end
    assert_response :success
    lesson = assigns(:lesson)
    course = assigns(:course)
    assert lesson
    assert course
    assert_equal 'hello one', lesson.name
    assert course.lessons.include?(lesson)
    assert_equal 'Created', flash[:notice]
  end

  test 'create invalid' do
    login(@gg)
    assert_no_difference('Lesson.count') do
      xhr :post, :create, :course_id => @course, :lesson => {:name => 'h'}
    end
    assert_equal flash[:error], 'Create failed'
  end

  test 'delete unauthorized' do
    lesson = lessons(:calculus)
    assert_no_difference('Lesson.count') do
      xhr :delete, :destroy, :course_id => @course, :id => lesson
    end
    assert_login_required
    login(@gg)
    course = @gg.learning_courses.last
    assert_no_difference('Lesson.count') do
      xhr :delete, :destroy, :course_id => course, :id => course.lessons.last
    end
    assert_unauthorized
  end

  test 'delete' do
    login(@gg)
    lesson = lessons(:calculus)
    assert_difference('Lesson.count', -1) do
      xhr :delete, :destroy, :course_id => lesson.course, :id => lesson
    end
    assert_equal flash[:notice], 'Deleted'
  end

  test 'update unauthorized' do
    lesson = @course.lessons.first
    xhr :put, :update, :course_id => @course, :id => lesson,
              :lesson => {:name => 'name updated'}
    assert_login_required
    lesson.reload
    assert_not_equal 'name updated', lesson.name
  end

  test 'update' do
    login(@gg)
    lesson = @course.lessons.first
    xhr :put, :update, :course_id => @course, :id => lesson,
              :lesson => {:name => 'name updated'}
    assert_response :success
    lesson.reload
    assert_equal lesson, assigns(:lesson)
    assert_equal lesson.name, 'name updated'
  end

  test 'update invalid attributes' do
    login(@gg)
    lesson = @course.lessons.first
    xhr :put, :update, :course_id => @course, :id => lesson,
              :lesson => {:name => nil}
    assert_response :success
    lesson.reload
    assert lesson.name
    assert_equal 'Update failed', flash[:error]
  end

  test 'update removes old attachments' do
    login(@gg)
    lesson = @course.lessons.first
    xhr :put, :update, :course_id => @course, :id => lesson,
              :lesson => {:name => 'name updated',
                          :upload => fixture_file_upload('uploads/test.pdf',
                                                         'application/pdf')}
    assert_response :success
    lesson.reload
    assert_equal lesson, assigns(:lesson)
    assert_equal lesson.name, 'name updated'
    assert_queued AttachmentDeleter
  end

  test 'delete attachment' do
    login(@gg)
    lesson = @course.lessons.first
    lesson.upload = upload('test.pdf')
    assert lesson.save
    xhr :delete, :delete_attachment, :course_id => @course, :id => lesson
    assert_response :success
    assert_equal 'Upload deleted', flash[:notice]
    assert_queued AttachmentDeleter
  end

  test 'show' do
    login(@gg)
    lesson = Lesson.last
    assert lesson.unread?(@gg)
    xhr :get, :show, :id => lesson, :course_id => @course
    assert_equal lesson, assigns(:lesson)
    assert !lesson.unread?(@gg)
  end

  test 'show unauthorized' do
    user = User.create!(:username => 'foobar', :fullname => 'Foobar', :password => 'password',
                        :password_confirmation => 'password', :email => 'foobar@akshi.com')
    login(user)
    lesson = Lesson.last
    xhr :get, :show, :id => lesson, :course_id => @course
    assert_unauthorized
  end

  test 'preview' do
    login(@gg)
    lesson = Lesson.last
    assert lesson.unread?(@gg)
    xhr :get, :preview, :id => lesson, :course_id => @course
    assert_equal lesson, assigns(:lesson)
  end

  test 'preview unauthorized' do
    user = User.create!(:username => 'foobar', :fullname => 'Foobar', :password => 'password',
                        :password_confirmation => 'password', :email => 'foobar@akshi.com')
    login(user)
    lesson = Lesson.last
    xhr :get, :preview, :id => lesson, :course_id => @course
    assert_unauthorized
  end

  test 'conversion complete' do
    login(@gg)
    lesson = @course.lessons.last
    lesson.upload = upload('test.pdf')
    lesson.save!
    xhr :get, :conversion_status, :id => lesson, :course_id => @course
    assert_equal lesson, assigns(:lesson)
    assert_template 'shared/viewers/_conversion_pending'

    file_path = lesson.upload.path
    FileUtils.touch "#{file_path.chomp(File.extname(file_path))}.converted"
    xhr :get, :conversion_status, :id => lesson, :course_id => @course
    assert_equal lesson, assigns(:lesson)
    assert_template 'shared/viewers/_document'
  end

  test 'sort' do
    login(@gg)
    calculus = lessons(:calculus)
    statistics = lessons(:statistics)
    math = courses(:math101)
    assert_equal [calculus, statistics], math.lessons
    xhr :put, :sort, :lesson => [statistics, calculus].map(&:id), :course_id => @course
    assert_equal [statistics, calculus], math.lessons.reload
  end

  test 'filter' do
    login(@gg)
    course = courses(:math101)
    xhr :get, :index, :course_id => course
    assert_equal 2, assigns(:lessons).count
    xhr :get, :index, :course_id => course, :filter => "Media"
    assert_equal 0, assigns(:lessons).count
    xhr :get, :index, :course_id => course, :filter => "Document"
    assert_equal 0, assigns(:lessons).count
    xhr :get, :index, :course_id => course, :filter => "All"
    assert_equal 2, assigns(:lessons).count
  end
end
