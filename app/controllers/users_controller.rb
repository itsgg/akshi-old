class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update]
  before_filter :load_user, :only => [:update_password, :show, :update,
                                      :courses]

  def new
    @user = User.new
  end

  def show
  end

  def courses
    case params[:course_type]
    when 'learning'
      @courses = @user.learning_courses
    when 'teaching'
      @courses = @user.teaching_courses.published
    end
    @courses = @courses.paginate :page => params[:page],
                                 :per_page => params[:per_page]
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      @success = true
      # Don't login by default when created by admin
      if params[:admin_create].blank?
        session[:current_user] = @user.id
      end
      flash[:notice] = t('register.registered')
    else
      flash.now[:error] = t('register.registration_failed')
    end
  end

  def forgot_password
  end

  def send_reset
    query = params[:username_email]
    @user = User.where(['username = ? or email = ?', query, query]).first
    if @user.present?
      @user.reset_password!
      @success = true
      flash[:notice] = t('forgot_password.reset_instruction')
    else
      flash.now[:error] = t('forgot_password.user_not_found')
    end
  end

  def reset_password
    @user = User.where(:id => params[:id],
                       :reset_password_token => params[:reset_password_token]
                      ).first
  end

  def update_password
    if @user.reset_password_token == params[:reset_password_token]
      @user.password_required = true
      attributes = params[:user].merge({:reset_password_token => nil})
      if @user.update_attributes(attributes)
        flash[:notice] = t('forgot_password.password_updated')
        session[:current_user] = @user.id
        @success = true
      else
        flash.now[:error] = t('forgot_password.update_failed')
      end
    else
      flash.now[:error] = t('forgot_password.invalid_token')
    end
  end

  def edit
    @user = current_user
  end

  def update
    case params[:operation]
    when 'reset_authentication_token'
      @user.reset_authentication_token
    else
      @old_avatar = @user.avatar(:large)
      @user.assign_attributes(params[:user])
    end

    if @user.save
      @success = true
      flash[:notice] = t('account.updated')
    else
      flash.now[:error] = t('account.update_failed')
    end
  end

  protected
  def load_user
    @user = User.find(params[:id])
  end

end
