class LessonsController < ApplicationController
  before_filter :authenticate, :except => [:download]
  before_filter :load_course, :except => [:download]
  before_filter :feature_enabled?, :except => [:download]
  before_filter :require_access, :except => [:download]
  before_filter :load_lesson, :only => [:update, :delete_attachment,
                                        :conversion_status, :destroy]
  before_filter :require_teacher, :except => [:index, :show, :preview,
                                              :conversion_status, :download]
  before_filter :load_lessons, :except => [:sort, :conversion_status, :download]

  def index
    @lesson = @lessons.first
    @lesson.mark_as_read! :for => current_user if @lesson.present?
  end

  def new
    @lesson = @course.lessons.new
  end

  def show
    if params[:paginate].present?
      @lesson = @lessons.first
    else
      @lesson = @course.lessons.find(params[:id])
    end
    @lesson.mark_as_read! :for => current_user
  end

  def preview
    @lesson = @course.lessons.find(params[:id])
  end

  def create
    @lesson = @course.lessons.new(params[:lesson])
    if @lesson.save
      @success = true
      flash[:notice] = t('lessons.created')
    else
      flash.now[:error] = t('lessons.create_failed')
    end
  end

  def download
    lesson = Lesson.find(params[:id])
    file_path = request.path
    ext_name = File.extname(file_path)
    if file_path.end_with?('_thumbnail.png')
      send_file File.join(Setting.upload.secure_location, file_path)
    else
      if current_user.nil? || !lesson.course.users.include?(current_user)
        access_denied
      else
        if Lesson::AUDIO_TYPE.include?(ext_name) || Lesson::VIDEO_TYPE.include?(ext_name)
          access_denied
        else
          send_file File.join(Setting.upload.secure_location, file_path)
        end
      end
    end
  end

  def update
    if params[:lesson][:upload].present?
      @lesson.delete_attachment! # Queue delete old attachments
    end
    if @lesson.update_attributes(params[:lesson])
      @success = true
      flash[:notice] = t('lessons.updated')
    else
      flash.now[:error] = t('lessons.update_failed')
    end
  end

  def delete_attachment
    @lesson.delete_attachment! # Queue delete
    flash[:notice] = t('lessons.upload_deleted')
  end

  def sort
    order = params[:lesson]
    @course.lessons.order!(order)
    render :text => order.inspect
  end

  def destroy
    @lesson.delete
    flash[:notice] = t('lessons.deleted')
  end

  def conversion_status
  end

  protected
  def load_course
    @course = Course.find(params[:course_id])
  end

  def feature_enabled?
    unless @course.feature_enabled?('lesson')
      access_denied
    end
  end

  def load_lessons
    lessons = nil
    subject = Subject.find_by_name(params[:subject])

    if current_user.teacher?(@course.id)
      unless subject.blank?
        lessons = subject.lessons
      else
        lessons = @course.lessons
      end
    end

    if current_user.student?(@course.id)
      unless subject.blank?
        lessons = subject.lessons.published
      else
        lessons = @course.lessons.published
      end
    end
    lessons = lessons.filter(params[:filter])
    @lessons = lessons.search(params[:q]).result.paginate :per_page => params[:per_page],
                                :page => params[:page]
  end

  def load_lesson
    @lesson = @course.lessons.find(params[:id])
    if current_user.student?(@course.id) && !@lesson.published?
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
