class CommentObserver < ActiveRecord::Observer
  def after_save(comment)
    if comment.review?
      admin_users = User.where(:admin => "1")
      admin_users.each do |admin|
        UserMailer.send_comment_review(admin.id, comment.id).deliver
      end
    end
  end
end
