# == Schema Information
#
# Table name: collections
#
#  id                          :integer          not null, primary key
#  name                        :string(255)
#  ancestry                    :string(255)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  position                    :integer
#  description                 :text
#  cover_file_name             :string(255)
#  cover_content_type          :string(255)
#  cover_file_size             :integer
#  cover_updated_at            :datetime
#  discount                    :integer
#  offline_payment_instruction :text
#  paid                        :boolean          default(TRUE)
#

class Collection < ActiveRecord::Base
  attr_accessible :name, :description, :position, :parent_id, :cover, :discount, :paid, :offline_payment_instruction

  validates :name, :presence => true,
                   :length => 3..80

  default_scope :order => 'collections.position ASC, collections.created_at DESC'

  validates_attachment :cover,
                       :size => {:less_than => Setting.upload.image_limit}

  has_attached_file :cover,
                    :styles => {:icon => '65x45#', :normal => '210x146#',
                                :large => '260x180#'},
                    :default_style => :normal, :url => :image_url,
                    :path => :image_path,
                    :default_url => '/assets/collections-placeholder-:style.png'

  has_and_belongs_to_many :courses
  has_ancestry

  def self.tree(nodes)
    if nodes.present?
      nodes.map do |node, sub_nodes|
        {:label => node.name, :children => self.tree(sub_nodes).compact,
         :count => node.courses.count, :id => node.id}
      end
    else
      []
    end
  end

  def cover_errors?
    self.errors[:cover_file_size].present? ||
    self.errors[:cover_content_type].present?
  end

  def amount_description
    amount = 0
    unless self.courses.blank?
      amount = self.courses.paid.map(&:amount).inject{|sum, x| sum + x}
    end
    amount.to_i != 0 ? "Rs #{amount.to_i}" : 'free'
  end

  def amount_description_paid(user)
    amount = amount_description
    total_course_amount = self.courses.paid.map(&:id)
    unless user.blank?
      user_learning_course = user.learning_courses.map(&:id)
      diff = total_course_amount - user_learning_course
    else
      diff = total_course_amount
    end
    final_amount = Course.find(diff).map(&:amount).inject{|sum, x| sum + x}
    unless (final_amount.blank? || self.discount.blank?)
      final_amount.to_i != 0 ? "Rs #{final_amount.to_i  - self.discount}" : 0
    else
      "Rs 0"
    end
  end

  def amount(user)
    unless self.discount.blank?
      amount_description_paid(user).split('Rs ')[1]
    else
      amount_description
    end
  end

  def enrolled?(user)
    user_learning_course = []
    unless user.blank?
      user_learning_course = self.courses.map(&:id) - user.learning_courses.map(&:id)
    end
    user_learning_course.empty?
  end

  def teacher?(user)
    user = User.find(user)
    puts self.courses.map(&:id)
    puts user.teaching_courses.map(&:id)
    unless user.teaching_courses.blank?
      user.teaching_courses.map(&:id).each do |course|
        if self.courses.map(&:id).include?(course)
          return true
        end
      end
    end
    false
  end

  def free_package?(user)
    return true if amount_description_paid(user) == 'free'
  end

  def full_description
    "#{name} - #{self.root.name}"
  end

  protected
  def image_path
    "#{Rails.root}/public#{self.image_url}"
  end

  def image_url
    '/system/:class/:attachment/:id/:style/:basename.:extension'
  end
end
