class Admin::CollectionsController < AdminController
  before_filter :load_collection, :only => [:edit, :update, :destroy]

  def index
    @collections = Collection.arrange(:order => :position)
    filtered_courses = Course.filter(current_user, params)
    @courses = filtered_courses.paginate :page => params[:page],
                               :per_page => params[:per_page]
  end

  def new
    @collection = Collection.new
  end

  def create
    @collection = Collection.new(params[:collection])
    if @collection.save
      @success = true
      flash[:notice] = t('collections.created')
    else
      flash.now[:error] = t('collections.create_failed')
    end
  end

  def edit
  end

  def update
    if @collection.update_attributes(params[:collection])
      @success = true
      flash[:notice] = t('collections.updated')
    else
      flash.now[:error] = t('collections.update_failed')
    end
  end

  def add_course
    course = Course.find(params[:course_id])
    collection = Collection.find(params[:id])
    if course.present? && collection.present? && !collection.courses.include?(course)
      collection.courses << course
      flash[:notice] = t('collections.course_added')
      @success = true
    end
  end

  def remove_course
    course = Course.find(params[:course_id])
    collection = Collection.find(params[:id])
    if collection.courses.delete(course)
      flash[:notice] = t('collections.course_removed')
      @success = true
    end
  end

  def destroy
    @collection.delete
    flash[:notice] = t('collections.deleted')
  end

  protected
  def load_collection
    @collection = Collection.find(params[:id])
  end
end
