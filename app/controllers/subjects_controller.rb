class SubjectsController < ApplicationController
    before_filter :load_subject, :only => [:edit, :update, :destroy]
    before_filter :load_course

  def index
    @subjects = @course.subjects.search(params[:q]).result
                          .paginate :page => params[:page],
                                    :per_page => params[:per_page]
  end

  def new
    @subject = Subject.new
  end

  def create
    @subject = @course.subjects.new(params[:subject])
    if @subject.save
      @success = true
      flash[:notice] = t('subjects.created')
    else
      flash.now[:error] = t('subjects.create_failed')
    end
  end

  def edit
  end

  def update
    if @subject.update_attributes(params[:subject])
      @success = true
      flash[:notice] = t('subjects.updated')
    else
      flash.now[:error] = t('subjects.update_failed')
    end
  end

  def destroy
    @subject.delete
    flash[:notice] = t('subjects.deleted')
  end

  def sort
    order = params[:subject]
    Subject.order!(order)
    render :text => order.inspect
  end

  protected
  def load_course
    @course = Course.find(params[:course_id])
  end

  private
  def load_subject
    @subject = Subject.find(params[:id])
  end
end
