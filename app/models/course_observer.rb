class CourseObserver < ActiveRecord::Observer
  def after_save(course)
    if course.review?
      User.admins.each do |admin|
        UserMailer.send_course_review(admin.id, course.id).deliver
      end
    end
  end
end
