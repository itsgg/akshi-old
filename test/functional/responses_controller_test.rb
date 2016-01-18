require 'test_helper'

class ResponsesControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
    @akshi = users(:akshi)
    @quiz = @gg.teaching_courses.last.quizzes.first
    @question = @quiz.questions.first
    @answer = @question.answers.first
  end

  test 'create not logged in' do
    assert_no_difference('Response.count') do
      xhr :post, :create, :quiz_id => @quiz,
          :response => {:answer_id => @answer, :question_id => @question}
    end
    assert_login_required
  end

  test 'create unauthorized' do
    login(@gg)
    assert_no_difference('Response.count') do
      xhr :post, :create, :quiz_id => @quiz,
          :response => {:answer_id => @answer, :question_id => @question}
    end
    assert_unauthorized
  end

  test 'create' do
    login(@akshi)
    Response.delete_all
    assert_difference('Response.count') do
      xhr :post, :create, :quiz_id => @quiz,
          :response => {:answer_id => @answer, :question_id => @question}
    end
    assert_nil assigns(:quiz_complete)
    assert_equal @akshi, assigns(:response).user
    assert_equal @quiz, assigns(:response).quiz
    assert_equal @answer, assigns(:response).answer
  end

  test 'create quiz session expired' do
    login(@akshi)
    @quiz.time_limit_in_minutes = 0.003
    @quiz.save!
    @quiz.start!(@akshi.id)
    sleep(2)
    assert_no_difference('Response.count') do
      xhr :post, :create, :quiz_id => @quiz,
          :response => {:answer_id => @answer, :question_id => @question}
    end
    assert assigns(:quiz_complete)
  end

  test 'should not create duplicate response' do
    login(@akshi)
    Response.delete_all
    assert_difference('Response.count') do
      xhr :post, :create, :quiz_id => @quiz,
          :response => {:answer_id => @answer, :question_id => @question}
    end
    assert_equal @akshi, assigns(:response).user
    assert_equal @quiz, assigns(:response).quiz
    assert_equal @answer, assigns(:response).answer
    assert_no_difference('Response.count') do
      xhr :post, :create, :quiz_id => @quiz,
          :response => {:answer_id => @question.answers.last, :question_id => @question}
    end
    assert_equal @akshi, assigns(:response).user
    assert_equal @quiz, assigns(:response).quiz
    assert_equal @question.answers.last, assigns(:response).answer
  end
end
