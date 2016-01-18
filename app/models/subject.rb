# == Schema Information
#
# Table name: subjects
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  course_id  :integer
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Subject < ActiveRecord::Base
  attr_accessible :course_id, :name
  has_many :announcements
  has_many :topics
  has_many :lessons
  has_and_belongs_to_many :quizzes
  belongs_to :course

  def self.order!(ids)
    if ids.present?
      update_all(
        ['position = FIND_IN_SET(id, ?)', ids.join(',')],
        {:id => ids})
    end
  end
end
