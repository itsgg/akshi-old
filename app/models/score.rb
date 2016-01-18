# == Schema Information
#
# Table name: scores
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  quiz_id         :integer
#  total_questions :integer          default(0)
#  correct_answers :integer          default(0)
#  start_time      :datetime
#  finished        :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Score < ActiveRecord::Base
  attr_accessible :user_id, :quiz_id, :total_questions, :correct_answers

  scope :finished, :conditions => {:finished => true}

  belongs_to :user
  belongs_to :quiz

  validates :user_id, :presence => true
  validates :quiz_id, :presence => true
  validates :total_questions, :presence => true
  validates :correct_answers, :presence => true

  def percent
    ((self.correct_answers/self.total_questions.to_f)*100).round(1)
  end
end
