# == Schema Information
#
# Table name: quiz_sessions
#
#  id         :integer          not null, primary key
#  quiz_id    :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class QuizSessionTest < ActiveSupport::TestCase
  setup do
    @gg = users(:gg)
    @quiz = quizzes(:verbs)
  end

  test 'presence validation' do
    quiz_session = QuizSession.new
    assert !quiz_session.save
    assert quiz_session.errors[:quiz].include?('is required')
    assert quiz_session.errors[:user].include?('is required')
  end

  test 'in_progress?' do
    @quiz.time_limit_in_minutes = 0.03 # 2 seconds
    @quiz.save!
    @quiz.start!(@gg.id)
    assert @gg.quiz_session.in_progress?
    sleep(3)
    assert !@gg.quiz_session.in_progress?
    assert @gg.quiz_session.expired?
  end

end
