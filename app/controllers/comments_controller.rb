class CommentsController < ApplicationController
  before_filter :admin_authenticate, :only => [:update_status]
  before_filter :load_post

  def new
    @comment = @post.comments.new
  end

  def create
    attributes = params[:comment]
    if logged_in?
      attributes.merge!(:user_id => current_user.id, :email => current_user.email)
    end

    @comment = @post.comments.new(attributes)
    if @comment.save
      @success = true
      flash[:notice] = t('comments.under_review')
    else
      flash.now[:error] = t('comments.create_failed')
    end
  end

  def update_status
    @comment = Comment.find(params[:comment_id])
    case params[:status]
    when 'approve'
      @comment.approve!
      flash.now[:notice] =  t('comments.approved')
    when 'reject'
      @comment.reject!
      flash.now[:notice] =  t('comments.rejected')
    end
    @comments = Comment.review.paginate :page => params[:page],
                                        :per_page => params[:per_page]
  end

  private
  def load_post
    @post = Post.find(params[:post_id])
  end
end
