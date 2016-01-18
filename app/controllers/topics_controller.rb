class TopicsController < ApplicationController
  before_filter :authenticate
  before_filter :load_course
  before_filter :feature_enabled?
  before_filter :require_access
  before_filter :load_topics
  before_filter :load_topic, :only => [:edit, :update, :destroy]
  before_filter :require_owner, :only => [:edit, :update]
  before_filter :require_teacher, :only => [:destroy]

  def index
    @topic = @topics.first
    @topic.mark_as_read! :for => current_user if @topic.present?
    @replies = @topic.children if @topic.present?
    @params_to_pass = {:type => params[:type], :subtype => params[:subtype],
                       :page => params[:page] || 1}
  end

  def new
    @topic = @course.topics.new
  end

  def show
    if params[:paginate].present?
      @topic = @topics.first
    else
      @topic = @course.topics.find(params[:id])
    end
    @topic.mark_as_read! :for => current_user
    @replies = @topic.children.paginate :per_page => params[:per_page],
                                        :page => params[:page]
    @params_to_pass = {:type => params[:type], :subtype => params[:subtype],
                       :page => params[:page] || 1}
  end

  def edit
  end

  def update
    if @topic.update_attributes(params[:topic])
      @success = true
      flash[:notice] = t('topics.updated')
    else
      flash.now[:error] = t('topics.update_failed')
    end
  end

  def create
    @topic = @course.topics.new(params[:topic]
                    .merge(:user_id => current_user.id,
                           :parent_id => params[:parent_id]))
    if @topic.save
      @success = true
      flash[:notice] = t('topics.created')
    else
      flash.now[:error] = t('topics.create_failed')
    end
  end

  def destroy
    @topic.delete
    flash[:notice] = t('topics.deleted')
  end

  protected
  def load_course
    @course = Course.find(params[:course_id])
  end

  def feature_enabled?
    unless @course.feature_enabled?('discussion')
      access_denied
    end
  end

  def load_topics
    topics = @course.topics.top
    subject = Subject.find_by_name(params[:subject])
    unless subject.blank?
      topics = subject.topics
    end
    @topics = topics.search(params[:q]).result.order('created_at DESC').paginate :per_page => params[:per_page],
                                :page => params[:page]
  end

  def load_topic
    @topic = @course.topics.find(params[:id])
  end

  def require_owner
    unless @topic.user == current_user
      access_denied
    end
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
end
