# == Schema Information
#
# Table name: posts
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  content    :text(2147483647)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Post < ActiveRecord::Base
  attr_accessible :content, :title, :user_id

  has_many :comments, :dependent => :destroy
  belongs_to :user

  validates :title, :presence => true, :length => 4..80
  validates :content, :presence => true
  validates :user_id, :presence => true

  default_scope :order => 'posts.created_at DESC'

  self.per_page = 15

  def brief_content
    if self.content.present?
      self.content.gsub(/<\/?.*?>/, '').gsub(/&nbsp;/i, ' ')
    end
  end
end
