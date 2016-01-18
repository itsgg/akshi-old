class Admin::CommentsController < AdminController

  def index
    @comments = Comment.review.paginate :page => params[:page],
                                       :per_page => params[:per_page]
  end
end
