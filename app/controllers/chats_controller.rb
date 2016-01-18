class ChatsController < ApplicationController
  before_filter :authenticate
  before_filter :load_course
  before_filter :require_access
  before_filter :load_chats

  def index
  end

  def show
    @chat = @course.chats.find(params[:id])
  end

  def create
    current_user_chats = @course.chats.where(:user_id => current_user.id)
    if current_user_chats.last.try(:content) == params[:chat][:content]
      render :nothing => true
    else
      @chat = @course.chats.new(params[:chat].merge(:user_id => current_user.id))
      if @chat.save
        @success = true
        flash.now[:notice] = t('chat.created')
      else
        flash.now[:error] = t('chat.create_failed')
      end
    end
  end

  protected
  def load_course
    @course = Course.find(params[:course_id])
  end

  def load_chats
    @chats = @course.chats.recent.limit(10)
  end

  def require_access
    if current_user.nil? || !@course.users.include?(current_user)
      access_denied
    end
  end
end
