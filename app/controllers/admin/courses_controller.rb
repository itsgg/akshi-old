class Admin::CoursesController < AdminController

  def index
    @courses = Course.review.paginate :page => params[:page],
                                      :per_page => params[:per_page]
  end
end
