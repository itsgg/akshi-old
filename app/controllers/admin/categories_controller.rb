class Admin::CategoriesController < AdminController
  before_filter :load_category, :only => [:edit, :update, :destroy]

  def index
    @categories = Category.search(params[:q]).result
                          .paginate :page => params[:page],
                                    :per_page => params[:per_page]
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(params[:category])
    if @category.save
      @success = true
      flash[:notice] = t('categories.created')
    else
      flash.now[:error] = t('categories.create_failed')
    end
  end

  def edit
  end

  def update
    if @category.update_attributes(params[:category])
      @success = true
      flash[:notice] = t('categories.updated')
    else
      flash.now[:error] = t('categories.update_failed')
    end
  end

  def destroy
    @category.delete
    flash[:notice] = t('categories.deleted')
  end

  def sort
    order = params[:category]
    Category.order!(order)
    render :text => order.inspect
  end

  private
  def load_category
    @category = Category.find(params[:id])
  end
end
