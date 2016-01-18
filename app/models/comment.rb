# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  post_id    :integer
#  content    :text
#  email      :string(255)
#  status     :string(255)      default("review")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class Comment < ActiveRecord::Base
  attr_accessible :content, :email, :post_id, :status, :user_id

  belongs_to :post
  belongs_to :user

  validates :email, :presence => true,
                    :format => {
                      :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
                    }, :allow_blank => true
  validates :content, :presence => true
  validates :post_id, :presence => true

  default_scope :order => 'comments.created_at DESC'

  scope :review, :conditions => {:status => 'review'}
  scope :approved, :conditions => {:status => 'approved'}

  self.per_page = 15

  def approved?
    self.status == 'approved'
  end

  def review?
    self.status == 'review'
  end

  def approve!
    self.update_attribute(:status, 'approved')
  end

  def reject!
    self.update_attribute(:status, 'rejected')
  end

  def review!
    self.update_attribute(:status, 'review')
  end
end
