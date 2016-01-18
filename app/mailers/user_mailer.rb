class UserMailer < AsyncMailer
  helper ApplicationHelper

  default :from => 'admin@akshi.com'

  def reset_password(user_id)
    @user = User.find(user_id)
    @reset_url = reset_password_user_url(@user,
                  :reset_password_token => @user.reset_password_token)
    @reset_path = reset_password_user_path(@user,
                  :reset_password_token => @user.reset_password_token)
    mail :to => @user.email do |format|
      format.html
      format.text
    end
  end

  def send_announcement(user_id, announcement_id)
    @user = User.find(user_id)
    @announcement = Announcement.find(announcement_id)
    @announcements_url = course_announcements_url(@announcement.course)
    @announcements_path = course_announcements_path(@announcement.course)
    mail :to => @user.email do |format|
      format.html
      format.text
    end
  end

  def send_schedule(user_id, schedule_id)
    @user = User.find(user_id)
    @schedule = Schedule.find(schedule_id)
    course = @schedule.course
    @live_url = course_live_url(course, :subtype => 'live', :type => 'learn')
    @live_path = course_live_path(course, :subtype => 'live', :type => 'learn')
    mail :to => @user.email do |format|
      format.html
      format.text
    end
  end

  def send_discussion(user_id, topic_id)
    @topic = Topic.find(topic_id)
    @user = User.find(user_id)
    @topic_url = course_topic_url(@topic.course, @topic.top)
    @topic_path = course_topic_path(@topic.course, @topic.top)
    mail :to => @user.email do |format|
      format.html
      format.text
    end
  end

  def send_course_review(admin_id, course_id)
    @admin = User.find(admin_id)
    @course = Course.find(course_id)
    mail :to => @admin.email do |format|
      format.html
      format.text
    end
  end

  def send_comment_review(admin_id, comment_id)
    @admin = User.find(admin_id)
    @comment = Comment.find(comment_id)
    @user_info = (@comment.user.blank? ? @comment.email : @comment.user.fullname)
    mail :to => @admin.email do |format|
      format.html
      format.text
    end
  end
end
