class PostsController < ApplicationController
  before_filter :admin_authenticate, :except => [:index, :show]
  before_filter :load_posts
  before_filter :load_post, :only => [:show, :edit, :update, :destroy]

  def index
    @params_to_pass = {:type => params[:type],
                       :page => params[:page] || 1}
    @posts = Post.search(params[:q])
                 .result.paginate :per_page => params[:per_page],
                                  :page => params[:page]
  end

  def show
    @comments = @post.comments.approved.paginate :per_page => params[:per_page],
                                                 :page => params[:page]
  end

  def edit
  end

  def new
    @post = current_user.posts.new
  end

  def create
    @post = current_user.posts.new(params[:post])
    if @post.save
      @success = true
      flash[:notice] = t('posts.created')
    else
      flash.now[:error] = t('posts.create_failed')
    end
  end

  def update
    if @post.update_attributes(params[:post])
      @success = true
      flash[:notice] = t('posts.updated')
    else
      flash.now[:error] = t('posts.update_failed')
    end
  end

  def destroy
    @post.delete
    flash[:notice] = t('posts.deleted')
  end

  private

  def load_posts
   @posts = Post.all
  end

  def load_post
   @post = Post.find(params[:id])
  end
end
