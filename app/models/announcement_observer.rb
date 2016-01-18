class AnnouncementObserver < ActiveRecord::Observer
  def after_create(annoucement)
    course = annoucement.course
    course.students.each do |student|
      if student.announcement_notify?
        UserMailer.send_announcement(student.id, annoucement.id).deliver
      end
    end
  end
end
