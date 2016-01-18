# == Schema Information
#
# Table name: topics
#
#  id         :integer          not null, primary key
#  content    :text(2147483647)
#  course_id  :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :integer
#  title      :string(255)
#  subject_id :integer
#

class Topic < ActiveRecord::Base
  attr_accessible :content, :course_id, :user_id, :parent_id, :title, :subject_id

  acts_as_readable :on => :created_at

  belongs_to :course
  belongs_to :user
  belongs_to :subject

  belongs_to :parent, :class_name => 'Topic'
  has_many :children, :class_name => 'Topic', :foreign_key => 'parent_id'

  validates :title, :presence => true, :length => 4..80, :if => :top?

  validates :content, :presence => true
  validates :course_id, :presence => true
  validates :user_id, :presence => true

  default_scope :order => 'topics.created_at DESC'
  scope :top, where(:parent_id => nil)

  self.per_page = 10

  def top?
    self.parent_id.blank?
  end

  def top
    top? ? self : self.parent
  end

  def brief_content
    if self.content.present?
      self.content.gsub(/<\/?.*?>/, '').gsub(/&nbsp;/i, ' ')
    end
  end
end
