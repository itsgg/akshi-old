require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
    @akshi = users(:akshi)
    @quiz = @gg.teaching_courses.last.quizzes.first
    @question = @quiz.questions.first
    @user = User.create!(:username => 'foobar', :fullname => 'Foobar',
                        :password => 'password',
                        :password_confirmation => 'password',
                        :email => 'foobar@akshi.com')
  end

  test 'index not logged in' do
    xhr :get, :index, :quiz_id => @quiz
    assert_login_required
  end

  test 'index unauthorized' do
    login(@user)
    xhr :get, :index, :quiz_id => @quiz
    assert_unauthorized
  end

  test 'index' do
    login(@gg)
    xhr :get, :index, :quiz_id => @quiz
    assert_response :success
    assert_equal @quiz.questions, assigns(:questions)
    assert_equal @quiz, assigns(:quiz)
    assert_equal @quiz.questions.first, assigns(:question)
    assert_nil assigns(:quiz_complete)
  end

  test 'index quiz session expire' do
    login(@akshi)
    @quiz.time_limit_in_minutes = 0.003
    @quiz.save!
    @quiz.start!(@akshi.id)
    sleep(2)
    xhr :get, :index, :quiz_id => @quiz
    assert_response :success
    assert assigns(:quiz_complete)
  end

  test 'show not logged in' do
    xhr :get, :show, :quiz_id => @quiz, :id => @question
    assert_login_required
  end

  test 'show unauthorized' do
    login(@user)
    xhr :get, :show, :quiz_id => @quiz, :id => @question
    assert_unauthorized
  end

  test 'show logged in' do
    login(@akshi)
    xhr :get, :show, :quiz_id => @quiz, :id => @question
    assert_response :success
    assert_equal @question, assigns(:question)
    assert_nil assigns(:quiz_complete)
  end

  test 'show quiz session expire' do
    login(@akshi)
    @quiz.time_limit_in_minutes = 0.003
    @quiz.save!
    @quiz.start!(@akshi.id)
    sleep(2)
    xhr :get, :show, :quiz_id => @quiz, :id => @question
    assert_response :success
    assert assigns(:quiz_complete)
  end

  test 'new not logged in' do
    xhr :get, :new, :quiz_id => @quiz
    assert_login_required
  end

  test 'new unauthorized' do
    login(@user)
    xhr :get, :new, :quiz_id => @quiz
    assert_unauthorized
  end

  test 'new' do
    login(@gg)
    xhr :get, :new, :quiz_id => @quiz
    assert_response :success
    assert assigns(:question).new_record?
  end

  test 'create not logged in' do
    assert_no_difference('Question.count') do
      xhr :post, :create, :quiz_id => @quiz, :question => {:content => 'foobar'}
    end
    assert_login_required
  end

  test 'create unauthorized' do
    login(@user)
    assert_no_difference('Question.count') do
      xhr :post, :create, :quiz_id => @quiz, :question => {:content => 'foobar'}
    end
    assert_unauthorized
  end

  test 'create' do
    login(@gg)
    assert_difference('Question.count') do
      xhr :post, :create, :quiz_id => @quiz, :question => {:content => 'foobar'}
    end
    assert_response :success
    assert_equal 'foobar', assigns(:question).content
  end

  test 'destroy not logged in' do
    assert_no_difference('Question.count') do
      xhr :delete, :destroy, :id => @question, :quiz_id => @quiz
    end
    assert_login_required
  end

  test 'destroy unauthorized' do
    login(@akshi)
    assert_no_difference('Question.count') do
      xhr :delete, :destroy, :id => @question, :quiz_id => @quiz
    end
    assert_unauthorized
  end

  test 'destroy' do
    login(@gg)
    assert_difference('Question.count', -1) do
      xhr :delete, :destroy, :id => @question, :quiz_id => @quiz
    end
    assert_response :success
    assert_equal 'Deleted', flash[:notice]
  end

  test 'edit' do
    login(@gg)
    xhr :get, :edit, :id => @question, :quiz_id => @quiz
    assert_response :success
    assert_equal @question, assigns(:question)
    assert_equal @quiz, assigns(:quiz)
  end

  test 'edit not logged in' do
    xhr :get, :edit, :id => @question, :quiz_id => @quiz
    assert_login_required
  end

  test 'edit unauthorized' do
    login(@user)
    xhr :get, :edit, :id => @question, :quiz_id => @quiz
    assert_unauthorized
  end

  test 'update' do
    login(@gg)
    xhr :put, :update, :id => @question, :quiz_id => @quiz,
        :question => {:content => 'Updated'}
    assert_response :success
    @question.reload
    assert_equal 'Updated', @question.content
  end

  test 'update logged in' do
    xhr :put, :update, :id => @question, :quiz_id => @quiz,
        :question => {:content => 'Updated'}
    assert_login_required
  end

  test 'update unauthorized' do
    login(@user)
    xhr :put, :update, :id => @question, :quiz_id => @quiz,
        :question => {:content => 'Updated'}
    assert_unauthorized
  end
end
