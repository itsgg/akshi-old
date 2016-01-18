# == Schema Information
#
# Table name: schedules
#
#  id          :integer          not null, primary key
#  description :string(255)
#  start_time  :datetime
#  course_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  mode        :string(255)      default("LIVE")
#  lesson_id   :integer
#

class Schedule < ActiveRecord::Base
  attr_accessible :description, :start_time, :course_id, :mode, :lesson_id

  belongs_to :course
  belongs_to :lesson

  validates :description, :presence => true, :length => 4..80
  validates :start_time, :presence => true
  validates :course_id, :presence => true
  scope :active, where('courses.status = "published"').joins(:course)
  scope :upcoming, where('schedules.start_time > ?', 1.hour.ago)
  default_scope :order => 'schedules.start_time'
end
