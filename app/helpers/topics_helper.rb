module TopicsHelper
  def topic_nav_link(topic, current_user)
    output = ''
    badge = ''
    if topic.user.teacher?(topic.course.id)
      badge = "<span class='label label-info' rel='tooltip' title='#{t('topics.posted_by_teacher')}'
                  >#{t('courses.teacher_icon')}</span> "
    end
    output = badge + (truncate output, :length => 100)
    if topic.unread?(current_user)
      output = "<strong>#{output}</strong>"
    end
    raw output
  end
end
