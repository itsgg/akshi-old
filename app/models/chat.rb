# == Schema Information
#
# Table name: chats
#
#  id         :integer          not null, primary key
#  content    :text(2147483647)
#  course_id  :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Chat < ActiveRecord::Base
  attr_accessible :content, :course_id, :user_id

  belongs_to :course
  belongs_to :user

  validates :content, :presence => true

  scope :recent, order('chats.created_at DESC')
end
