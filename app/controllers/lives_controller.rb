class LivesController < ApplicationController
  before_filter :authenticate
  before_filter :load_course
  before_filter :feature_enabled?
  before_filter :require_access
  before_filter :load_chats

  def show
    @slides = @course.document_lessons
    if params[:change_slide].present?
      @current_slide = Lesson.find(params[:slide_id])
    else
      @current_slide = @slides.first
    end
    @next_class = @course.schedules.upcoming.first if @course.schedules.upcoming.present?
  end

  protected
  def load_course
    @course = Course.find(params[:course_id])
  end

  def feature_enabled?
    unless @course.feature_enabled?('live')
      access_denied
    end
  end

  def load_chats
    @chats = @course.chats.recent.limit(10)
    @chats.reload
  end

  def require_access
    unless @course.users.include?(current_user)
      access_denied
    end
  end
end
