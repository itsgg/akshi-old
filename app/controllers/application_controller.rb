class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :logged_in?, :logged_in_as_admin?

  # Don't verify authenticity tokens for JSON requests
  skip_filter :verify_authenticity_token, :if => proc { |controller|
    format = controller.request.format
    format && format.json?
  }

  def current_user
    if params[:token].present?
      return User.find_by_authentication_token!(params[:token])
    end
    User.find(session[:current_user])
  rescue ActiveRecord::RecordNotFound
    session[:current_user] = nil
  end

  def logged_in?
    current_user.present?
  end

  def logged_in_as_admin?
    current_user.try(:admin?)
  end

  def authenticate
    unless logged_in?
      flash.now[:error] = t('login.login_required')
      render 'sessions/new'
    end
  end

  def admin_authenticate
    if logged_in?
      access_denied unless logged_in_as_admin?
    else
      authenticate
    end
  end

  def access_denied
    if Rails.env.test?
      render :nothing => true, :status => :unauthorized
    else
      respond_to do |wants|
        wants.js {
          render :js => "window.showFlash('#{t('site.access_denied')}', 'error')"
        }
        wants.json {
          render :nothing => true, :status => :unauthorized
        }
      end
    end
  end
end
