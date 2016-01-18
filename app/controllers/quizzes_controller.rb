class QuizzesController < ApplicationController
  before_filter :authenticate
  before_filter :load_course
  before_filter :feature_enabled?
  before_filter :require_access
  before_filter :require_teacher, :except => [:index, :complete, :show]
  before_filter :load_quizzes
  before_filter :load_quiz, :only => [:update, :complete, :destroy, :results]

  def index
    @quiz = @quizzes.first
    @quiz.mark_as_read! :for => current_user if @quiz.present?
  end

  def show
    if params[:paginate].present?
      @quiz = @quizzes.first
    else
      @quiz = @course.quizzes.find(params[:id])
    end
    @quiz.mark_as_read! :for => current_user
  end

  def new
    @quiz = @quizzes.new
  end

  def complete
    if @quiz.current_session(current_user.id).try(:expired?)
      flash[:notice] = t('quizzes.times_up')
    end
    @quiz.finish!(current_user.id)
  end

  def create
    @quiz = @quizzes.new(params[:quiz])
    if @quiz.save
      @success = true
      flash[:notice] = t('quizzes.created')
    else
      flash.now[:error] = t('quizzes.create_failed')
    end
  end

  def update
    if !@quiz.published? &&
       params[:quiz][:published] == '1' &&
       @quiz.questions.map(&:correct_answer).include?(nil)
      flash.now[:error] = t('quizzes.correct_answer_missing')
    else
      if @quiz.update_attributes(params[:quiz])
        @success = true
        flash[:notice] = t('quizzes.updated')
      else
        flash.now[:error] = t('quizzes.update_failed')
      end
    end
  end

  def destroy
    @quiz.delete
    flash[:notice] = t('quizzes.deleted')
  end

  def results
    @scores = @quiz.scores.finished.sort_by(&:correct_answers).reverse
                   .paginate :per_page => 15,
                             :page => params[:results_page]
  end

  protected
  def load_course
    @course = Course.find(params[:course_id])
  end

  def feature_enabled?
    unless @course.feature_enabled?('quiz')
      access_denied
    end
  end

  def require_teacher
    unless current_user.teacher?(@course.id)
      access_denied
    end
  end

  def load_quiz
    @quiz = @course.quizzes.find(params[:id])
    if current_user.student?(@course.id) && !@quiz.published?
      access_denied
    end
  end

  def require_access
    if !@course.users.include?(current_user)
      access_denied
    end
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
end
