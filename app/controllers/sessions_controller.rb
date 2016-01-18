class SessionsController < ApplicationController
  def new
    reset_session
  end

  def create
    @user = User.find(:first, :conditions => ["BINARY username = ?", params[:username]])
    if @user.try(:authenticate, params[:password])

      if @user.blocked?
        flash.now[:error] = t('login.blocked')
      else
        # Reset the old session
        if @user.session_id.present?
          # Old session
          old_session = Session.find_by_session_id(@user.session_id)
          old_session.destroy if old_session.present?
        end
        @user.update_attribute(:session_id, request.session_options[:id])
        @success = true
        session[:current_user] = @user.id
        flash[:notice] = t('login.logged_in')
      end
    else
      flash.now[:error] = t('login.invalid')
    end
  end

  def destroy
    reset_session
    flash[:notice] = t('login.logged_out')
  end
end
