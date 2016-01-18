module LessonsHelper
  def lesson_nav_link(lesson)
    icon_class = "file"
    if lesson.upload.present?
      ext_name = File.extname(lesson.upload.path)
      if Lesson::VIDEO_TYPE.include?(ext_name)
        icon_class = 'icon-film'
      end
      if Lesson::AUDIO_TYPE.include?(ext_name)
        icon_class = 'icon-headphones'
      end
      if Lesson::DOCUMENT_TYPE.include?(ext_name)
        icon_class = 'icon-file'
      end
    else
      icon_class = 'icon-question-sign'
    end
    output = "<i class='#{icon_class}' /> #{lesson.name}"
    if lesson.unread?(current_user)
      output = "<strong>#{output}</strong>"
    end
    raw output
  end
end
