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

class QuizSession < ActiveRecord::Base
  attr_accessible :user, :quiz

  belongs_to :quiz
  belongs_to :user

  validates :quiz, :presence => true
  validates :user, :presence => true

  def in_progress?
    self.remaining_time_in_seconds > 0
  end

  def expired?
    self.quiz.time_limit_in_minutes > 0 && !self.in_progress?
  end

  def elapsed_time_in_seconds
    (Time.now - self.created_at).round
  end

  def remaining_time_in_seconds
    (self.quiz.time_limit_in_minutes * 60) - self.elapsed_time_in_seconds
  end
end
