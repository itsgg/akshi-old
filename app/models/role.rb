# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  user_id    :integer
#  course_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Role < ActiveRecord::Base
  attr_accessible :name, :user, :course

  belongs_to :user
  belongs_to :course

  validates :name, :presence => true
  validates :user, :presence => true
  validates :course, :presence => true
end
