require 'test_helper'

class QuizzesControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
    @akshi = users(:akshi)
    @course = @gg.teaching_courses.first
  end

  test 'list unauthorized' do
    xhr :get, :index, :course_id => @course
    assert_login_required
    login(@gg)
  end

  test 'list' do
    login(@gg)
    xhr :get, :index, :course_id => @course
    assert_response :success
    assert_equal @course, assigns(:course)
    assert_equal @course.quizzes, assigns(:quizzes)
  end

  test 'new unauthorized' do
    xhr :get, :new, :course_id => @course
    assert_login_required
    login(@gg)
    xhr :get, :new, :course_id => @gg.learning_courses.last
    assert_unauthorized
  end

  test 'new' do
    login(@gg)
    xhr :get, :new, :course_id => @course
    assert_response :success
    assert_equal @course, assigns(:course)
    assert assigns(:quiz).new_record?
  end

  test 'create unauthorized' do
    xhr :post, :create, :course_id => @course, :quiz => {:name => 'Test quiz'}
    assert_login_required
    login(@gg)
    xhr :post, :create, :course_id => @gg.learning_courses.last,
                        :quiz => {:name => 'blah'}
    assert_unauthorized
  end

  test 'create' do
    login(@gg)
    assert_difference('Quiz.count') do
      xhr :post, :create, :course_id => @course, :quiz => {:name => 'blah'}
    end
    assert_response :success
    assert assigns(:course)
    assert_equal 'blah', assigns(:quiz).name
  end

  test 'update' do
    login(@gg)
    quiz = @course.quizzes.first
    xhr :put, :update, :course_id => @course, :id => quiz,
              :quiz => {:name => 'name updated'}
    assert_response :success
    quiz.reload
    assert_equal quiz, assigns(:quiz)
    assert_equal quiz.name, 'name updated'
  end

  test 'update feature disabled' do
    login(@gg)
    @course.features = ['announcement']
    assert @course.save
    quiz = @course.quizzes.first
    xhr :put, :update, :course_id => @course, :id => quiz,
              :quiz => {:name => 'name updated'}
    assert_unauthorized
  end

  test 'update unauthorized' do
    quiz = @course.quizzes.first
    xhr :put, :update, :course_id => @course, :id => quiz,
              :quiz => {:name => 'name updated'}
    assert_login_required
    quiz.reload
    assert_not_equal 'name updated', quiz.name
  end

  test 'update invalid attributes' do
    login(@gg)
    quiz = @course.quizzes.first
    xhr :put, :update, :course_id => @course, :id => quiz,
              :quiz => {:name => nil}
    assert_response :success
    quiz.reload
    assert quiz.name
    assert_equal 'Update failed', flash[:error]
  end

  test 'delete unauthorized' do
    quiz = quizzes(:prob)
    assert_no_difference('Quiz.count') do
      xhr :delete, :destroy, :course_id => quiz.course, :id => quiz
    end
    assert_login_required
    login(@gg)
    course = @gg.learning_courses.last
    assert_no_difference('Quiz.count') do
      xhr :delete, :destroy, :course_id => course, :id => course.quizzes.last
    end
    assert_unauthorized
  end

  test 'delete' do
    login(@gg)
    quiz = quizzes(:prob)
    assert_difference('Quiz.count', -1) do
      xhr :delete, :destroy, :course_id => quiz.course, :id => quiz
    end
    assert_equal flash[:notice], 'Deleted'
  end

  test 'results not logged in' do
    xhr :get, :results, :course_id => @course, :id => @course.quizzes.first
    assert_login_required
  end

  test 'results unauthorized' do
    login(@akshi)
    xhr :get, :results, :course_id => @course, :id => @course.quizzes.first
    assert_unauthorized
  end

  test 'results' do
    login(@gg)
    quiz = @course.quizzes.first
    quiz.scores.each do |score|
      score.update_attribute('finished', true)
    end
    xhr :get, :results, :course_id => @course, :id => quiz
    assert_response :success
    assert_equal quiz.scores.size, assigns(:scores).size
  end
end
