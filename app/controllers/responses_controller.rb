class ResponsesController < ApplicationController
  before_filter :authenticate
  before_filter :load_quiz
  before_filter :load_course
  before_filter :require_student_access

  def create
    if @quiz.current_session(current_user.id).try(:expired?)
      flash[:notice] = t('quizzes.times_up')
      @quiz_complete = true
      @quiz.finish!(current_user.id)
    else
      @response = @quiz.responses.find_by_user_id_and_question_id(current_user.id,
                                        params[:response][:question_id])
      if @response.present?
        success = @response.update_attributes(params[:response])
      else
        @response = @quiz.responses.new(params[:response].merge(:user_id => current_user.id))
        success = true if @response.save
      end
      unless success
        flash.now[:error] = t('responses.failed')
      end
    end
  end

  protected
  def load_quiz
    @quiz = Quiz.find(params[:quiz_id])
  end

  def load_course
    @course = @quiz.course
  end

  def require_student_access
    if !@course.students.include?(current_user)
      access_denied
    end
  end
end
