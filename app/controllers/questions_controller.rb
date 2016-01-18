class QuestionsController < ApplicationController
  before_filter :authenticate
  before_filter :load_quiz
  before_filter :load_questions
  before_filter :load_question, :only => [:show, :edit, :update]
  before_filter :load_course
  before_filter :require_access
  before_filter :require_teacher, :except => [:index, :show]
  before_filter :load_quizzes

  def index
    @question = @questions.first
    if @question.present?
      @user_response = @question.responses.find_by_user_id(current_user)
    end
    if current_user.student?(@course.id) && !@quiz.completed?(current_user.id)
      # Finish quiz if the timer expires
      if @quiz.current_session(current_user.id).try(:expired?)
        flash[:notice] = t('quizzes.times_up')
        @quiz_complete = true
        @quiz.finish!(current_user.id)
      else
        @quiz.start!(current_user.id) if @quiz.current_session(current_user.id).blank?
      end
    end
  end

  def show
    @user_response = @question.responses.find_by_user_id(current_user)
    if current_user.student?(@course.id) && !@quiz.completed?(current_user.id)
      # Finish quiz if the timer expires
      if @quiz.current_session(current_user.id).try(:expired?)
        flash[:notice] = t('quizzes.times_up')
        @quiz_complete = true
        @quiz.finish!(current_user.id)
      end
    end
  end

  def new
    @question = @questions.new
  end

  def edit
  end

  def update
    if @question.update_attributes(params[:question])
      @success = true
      flash[:notice] = t('questions.updated')
    else
      flash.now[:error] = t('questions.update_failed')
    end
  end

  def create
    @question = @questions.new(params[:question])
    if @question.save
      @success = true
      flash[:notice] = t('questions.created')
    else
      flash.now[:error] = t('questions.create_failed')
    end
  end

  def destroy
    @question = @questions.find(params[:id])
    @question.delete
    flash[:notice] = t('questions.deleted')
  end

  protected
  def load_quiz
    @quiz = Quiz.find(params[:quiz_id])
  end

  def load_course
    @course = @quiz.course
  end

  def load_quizzes
    subject = Subject.find_by_name(params[:subject])
    if current_user.teacher?(@course.id)
      unless subject.blank?
        quizzes = subject.quizzes
      else
        quizzes = @course.quizzes
      end
    end
    if current_user.student?(@course.id)
      unless subject.blank?
        quizzes = subject.quizzes.published
      else
        quizzes = @course.quizzes.published
      end
    end
    quizzes = quizzes.search(params[:q]).result
    @quizzes = quizzes.paginate :per_page => params[:per_page],
                                :page => params[:page]
  end

  def load_questions
    @questions = @quiz.questions
                      .paginate :per_page => 1,
                                :page => params[:question_page]
  end

  def load_question
    @question = @questions.find(params[:id])
  end

  def require_access
    if !@course.users.include?(current_user)
      access_denied
    end
  end

  def require_teacher
    unless current_user.teacher?(@course.id)
      access_denied
    end
  end
end
