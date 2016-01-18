class RatingsController < ApplicationController
  before_filter :authenticate
  before_filter :load_course
  before_filter :require_student

  def create
    @rating = @course.ratings.new(params[:ratings].merge(:owner_id => current_user.id))
    if @rating.save
      @course.rate!
      flash[:notice] = t('ratings.success')
    else
      flash[:error] = t('ratings.failure')
    end
  end

  protected
  def load_course
    @course = Course.find(params[:course_id])
  end

  def require_student
    unless current_user.student?(@course.id)
      access_denied
    end
  end
end
