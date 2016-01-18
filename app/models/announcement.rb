# == Schema Information
#
# Table name: announcements
#
#  id         :integer          not null, primary key
#  content    :text(2147483647)
#  course_id  :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  subject_id :integer
#

class Announcement < ActiveRecord::Base
  attr_accessible :content, :user_id, :course_id, :subject_id

  belongs_to :user
  belongs_to :course
  belongs_to :subject

  validates :content, :presence => true
  validates :user_id, :presence => true
  validates :course_id, :presence => true

  default_scope :order => 'announcements.created_at DESC'

  self.per_page = 10

  def brief_content
    if self.content.present?
      self.content.gsub(/<\/?.*?>/, '').gsub(/&nbsp;/i, ' ')
    end
  end
end
