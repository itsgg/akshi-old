class AnswersController < ApplicationController
  before_filter :authenticate
  before_filter :load_question
  before_filter :load_quiz
  before_filter :load_course
  before_filter :require_access
  before_filter :load_quizzes
  before_filter :load_answer, :except => [:new, :create]
  before_filter :require_teacher

  def new
    @answer = @question.answers.new
  end

  def edit
  end

  def update
    if @answer.update_attributes(params[:answer])
      @success = true
      flash[:notice] = t('answers.updated')
    else
      flash.now[:error] = t('answers.update_failed')
    end
  end

  def create
    @answer = @question.answers.new(params[:answer])
    if @answer.save
      @success = true
      flash[:notice] = t('answers.created')
    else
      flash.now[:error] = t('answers.create_failed')
    end
  end

  def destroy
    @answer.delete
    flash[:notice] = t('answers.deleted')
  end

  private
  def load_question
    @question = Question.find(params[:question_id])
  end

  def load_quiz
    @quiz = @question.quiz
  end

  def load_course
    @course = @quiz.course
  end

  def load_quizzes
    @quizzes = @course.quizzes.paginate :per_page => params[:per_page],
                                        :page => params[:page]
  end

  def load_answer
    @answer = @question.answers.find(params[:id])
  end

  def require_teacher
    unless current_user.teacher?(@course.id)
      access_denied
    end
  end

  def require_access
    unless @course.users.include?(current_user)
      access_denied
    end
  end
end
