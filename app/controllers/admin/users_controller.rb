class Admin::UsersController < AdminController
  before_filter :load_user, :except => [:index, :import]

  def index
    @users = User.order('created_at DESC').search(params[:q])
                 .result.paginate :per_page => params[:per_page],
                                   :page => params[:page]
  end

  def shadow
    reset_session
    session[:current_user] = @user.id
    flash[:notice] = t('login.logged_in')
  end

  def courses
    @courses = Course.published.search(params[:q]).result
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = t('users.updated')
    else
      flash[:error] = t('users.update_failed')
    end
  end

  def enroll
    course = Course.find(params[:course_id])
    if params[:checked] == 'true'
      course.add_student(@user)
    else
      course.students.delete(@user)
    end
    render :nothing => true
  end

  def import
  end

  def destroy
    @user.delete
    flash[:notice] = t('users.deleted')
  end

  protected
  def load_user
    @user = User.find(params[:id])
  end

end
