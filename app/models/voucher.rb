# == Schema Information
#
# Table name: vouchers
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  status     :string(255)      default("new")
#  course_id  :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Voucher < ActiveRecord::Base
  @@retries = 0
  attr_accessible :code, :status, :course_id, :user_id

  scope :active, :conditions => {:status => 'active'}
  scope :used, :conditions => {:status => 'used'}
  scope :available, :conditions => {:status => 'new'}

  belongs_to :course
  belongs_to :user

  validates :code, :presence => true
  validates :code, :uniqueness => { :scope => :course_id }
  validates :course_id, :presence => true
  validates :status, :presence => true

  self.per_page = 5

  FILTER_TYPE = ["All", "New", "Active", "Used"]

  def self.generate!(course_id, quantity = 10, length = 6, allowed_chars = (0..9).to_a)
    quantity.to_i.times do
      Voucher.create! :code => self.generate_unique_code(course_id, length, allowed_chars),
                      :course_id => course_id
    end
  end

  def self.generate_unique_code(course_id, length, allowed_chars)
    course = Course.find(course_id)
    unique_code = self.generate_voucher_code(length, allowed_chars)

    if course.vouchers.map(&:code).include?(unique_code)
      raise 'Cannot generate unique code' if @@retries > 20
      @@retries += 1
      self.generate_unique_code(course_id, length, allowed_chars)
    else
      unique_code
    end
  end

  def self.generate_voucher_code(length, allowed_chars)
    (0...length).collect{allowed_chars[Kernel.rand(allowed_chars.length)]}.join
  end

  def status_valid?
    self.course.vouchers.active.map(&:code).include?(self.code)
  end

  def status_active?
    self.status == 'active'
  end

  def status_new?
    self.status == 'new'
  end

  def status_used?
    self.status == 'used'
  end

  def activate!
    self.update_attribute(:status, 'active')
  end

  def deactivate!
    self.update_attribute(:status, 'new')
  end

  def use!
    self.update_attribute(:status, 'used')
  end

  def self.filter(course, params)
    vouchers = []
    case params[:filter]
    when "Used"
      vouchers = course.vouchers.used
    when "Active"
      vouchers = course.vouchers.active
    when "New"
      vouchers = course.vouchers.available
    else
      vouchers = course.vouchers
    end
    if params[:q].try(:[], 'code_cont').present?
      vouchers = vouchers.search(params[:q]).result
    end
    vouchers
  end
end
