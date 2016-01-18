module QuizzesHelper
  def quiz_nav_link(quiz)
    output = quiz.name
    if quiz.unread?(current_user)
      output = "<strong>#{quiz.name}</strong>"
    end
    raw quiz.name
  end
end
