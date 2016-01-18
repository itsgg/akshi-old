# == Schema Information
#
# Table name: answers
#
#  id          :integer          not null, primary key
#  content     :text(2147483647)
#  question_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Answer < ActiveRecord::Base
  attr_accessible :content, :question_id

  belongs_to :question

  validates :content, :presence => true
  validates :question_id, :presence => true
end
