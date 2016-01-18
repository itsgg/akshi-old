class AnnouncementsController < ApplicationController
  before_filter :authenticate
  before_filter :load_course
  before_filter :feature_enabled?
  before_filter :require_access
  before_filter :require_teacher, :except => [:index]
  before_filter :load_announcement, :only => [:edit, :update, :destroy]
  before_filter :load_announcements, :only => [:index]

  def index
    @params_to_pass = { :type => params[:type],
                        :subtype => params[:subtype],
                        :page => params[:page] || 1 }
  end

  def new
    @announcement = @course.announcements.new
  end

  def create
    @announcement = @course.announcements.new(params[:announcement]
                           .merge(:user_id => current_user.id))
    if @announcement.save
      @success = true
      flash[:notice] = t('announcements.created')
    else
      flash.now[:error] = t('announcements.create_failed')
    end
  end

  def edit
  end

  def update
    if @announcement.update_attributes(params[:announcement])
      @success = true
      flash[:notice] = t('announcements.updated')
    else
      flash.now[:error] = t('announcements.update_failed')
    end
  end

  def destroy
    @announcement.delete
    flash[:notice] = t('announcements.deleted')
  end

  protected
  def load_course
    @course = Course.find(params[:course_id])
  end

  def feature_enabled?
    unless @course.feature_enabled?('announcement')
      access_denied
    end
  end

  def load_announcement
    @announcement = Announcement.find(params[:id])
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

  def load_announcements
    announcements = @course.announcements
    subject = Subject.find_by_name(params[:subject])
    unless subject.blank?
      announcements = subject.announcements
    end
    @announcements = announcements.search(params[:q]).result.paginate :per_page => params[:per_page],
                                             :page => params[:page]
  end
end
