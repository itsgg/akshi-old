class SchedulesController < ApplicationController
  before_filter :authenticate
  before_filter :load_course
  before_filter :load_schedules
  before_filter :require_access
  before_filter :require_teacher, :only => [:create, :update, :destroy]

  def index
    @schedule = Schedule.new
  end

  def create
    start_time = params[:schedule][:start_time]
    parsed_start_time = parse_start_time(start_time)
    if parsed_start_time[:status] == 'failed'
      flash.now[:error] = parsed_start_time[:message]
    else
      @schedule = @course.schedules.new(params[:schedule]
                         .merge(:start_time => parsed_start_time[:message]))
      if @schedule.save
        @success = true
        flash.now[:notice] = t('schedules.scheduled')
      else
        flash.now[:error] = @schedule.errors.full_messages.first
      end
    end
  end

  def destroy
    @schedule = @course.schedules.find(params[:id])
    @schedule.delete
    flash.now[:notice] = t('schedules.deleted')
  end

  protected
  def load_course
    @course = Course.find(params[:course_id])
  end

  def parse_start_time(start_time)
    if start_time.blank?
      return {
        :status => 'failed',
        :message => 'Start time is required'
      }
    end
    parsed_time = Chronic.parse(start_time)
    if parsed_time.blank?
      return {
        :status => 'failed',
        :message => 'Start time is invalid'
      }
    end
    if parsed_time < Time.now
      return {
        :status => 'failed',
        :message => 'Start time should be in future'
      }
    end
    return {
      :status => 'success',
      :message => parsed_time
    }
  end

  def load_schedules
    @schedules = @course.schedules.upcoming
  end

  def require_access
    unless @course.users.include?(current_user)
      access_denied
    end
  end

  def require_teacher
    unless current_user.teacher?(@course.id)
      access_denied
    end
  end
end
