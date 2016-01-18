require 'test_helper'

class AnswersControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
    @akshi = users(:akshi)
    @quiz = @gg.teaching_courses.last.quizzes.first
    @question = @quiz.questions.first
    @answer = @question.answers.last
    @user = User.create! :username => 'foobar', :fullname => 'Foobar',
                         :password => 'password',
                         :password_confirmation => 'password',
                         :email => 'foobar@akshi.com'
  end

  test 'new not logged in' do
    xhr :get, :new, :question_id => @question
    assert_login_required
  end

  test 'new unauthorized' do
    login(@user)
    xhr :get, :new, :question_id => @question
    assert_unauthorized
  end

  test 'new' do
    login(@gg)
    xhr :get, :new, :question_id => @question
    assert_response :success
    assert assigns(:answer).new_record?
  end

  test 'create not logged in' do
    assert_no_difference('Answer.count') do
      xhr :post, :create, :question_id => @question, :answer => {:content => 'foobar'}
    end
    assert_login_required
  end

  test 'create unauthorized' do
    login(@user)
    assert_no_difference('Answer.count') do
      xhr :post, :create, :question_id => @question, :answer => {:content => 'foobar'}
    end
    assert_unauthorized
  end

  test 'create' do
    login(@gg)
    assert_difference('Answer.count') do
      xhr :post, :create, :question_id => @question, :answer => {:content => 'foobar'}
    end
    assert_response :success
    assert_equal 'foobar', assigns(:answer).content
  end

  test 'delete' do
    login(@gg)
    assert_difference('Answer.count', -1) do
      xhr :delete, :destroy, :question_id => @question, :id => @answer
    end
    assert_response :success
    assert_equal 'Deleted', flash[:notice]
  end

  test 'delete not logged in' do
    assert_no_difference('Answer.count') do
      xhr :delete, :destroy, :question_id => @question, :id => @answer
    end
    assert_login_required
  end

  test 'delete unauthorized' do
    login(@user)
    assert_no_difference('Answer.count') do
      xhr :delete, :destroy, :question_id => @question, :id => @answer
    end
    assert_unauthorized
  end

  test 'edit' do
    login(@gg)
    xhr :get, :edit, :question_id => @question, :id => @answer
    assert_response :success
    assert_equal @answer, assigns(:answer)
  end

  test 'edit not logged in' do
    xhr :get, :edit, :question_id => @question, :id => @answer
    assert_login_required
  end

  test 'edit unauthorized' do
    login(@user)
    xhr :get, :edit, :question_id => @question, :id => @answer
    assert_unauthorized
  end

  test 'update' do
    login(@gg)
    xhr :put, :update, :question_id => @question, :id => @answer,
        :answer => {:content => 'Updated'}
    assert_response :success
    assert_equal 'Updated', flash[:notice]
    @answer.reload
    assert_equal 'Updated', @answer.content
    assert_equal @answer, assigns(:answer)
  end

  test 'update not logged in' do
    xhr :put, :update, :question_id => @question, :id => @answer,
        :answer => {:content => 'Updated'}
    assert_login_required
  end

  test 'update unauthorized' do
    login(@user)
    xhr :put, :update, :question_id => @question, :id => @answer,
        :answer => {:content => 'Updated'}
    assert_unauthorized
  end
end

