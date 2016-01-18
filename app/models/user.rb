# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  username             :string(255)
#  fullname             :string(255)
#  email                :string(255)
#  about                :text(2147483647)
#  password_digest      :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  avatar_file_name     :string(255)
#  avatar_content_type  :string(255)
#  avatar_file_size     :integer
#  avatar_updated_at    :datetime
#  reset_password_token :string(255)
#  authentication_token :string(255)
#  announcement_notify  :boolean          default(TRUE)
#  admin                :boolean          default(FALSE)
#  discussion_notify    :boolean          default(TRUE)
#  blocked              :boolean          default(FALSE)
#  session_id           :text
#  schedule_notify      :boolean          default(TRUE)
#  phone_number         :string(255)
#  state_city           :string(255)
#  institution          :string(255)
#  date_of_birth        :string(255)
#

require 'digest/md5'

class User < ActiveRecord::Base
  attr_accessible :about, :email, :fullname, :password, :password_confirmation,
                  :username, :avatar, :reset_password_token,
                  :authentication_token, :announcement_notify, :discussion_notify, 
                  :admin, :blocked, :schedule_notify,
                  :date_of_birth, :phone_number, :institution, :state_city
  attr_accessor :password, :password_confirmation, :password_required
  acts_as_reader

  scope :admins, where(:admin => true)

  has_many :posts
  has_many :roles, :dependent => :destroy
  has_many :topics, :dependent => :destroy
  has_many :announcements, :dependent => :destroy
  has_many :chats, :dependent => :destroy
  has_many :responses, :dependent => :destroy
  has_many :scores, :dependent => :destroy
  has_many :teaching_courses, :through => :roles, :source => :course,
                              :conditions => "roles.name = 'teacher'"
  has_many :learning_courses, :through => :roles, :source => :course,
                              :conditions => "roles.name = 'student'"
  has_attached_file :avatar,
                    :styles => {:icon => '40x40#', :normal => '80x80#',
                                :large => '100x100#'},
                    :default_style => :normal, :url => :image_url,
                    :path => :image_path,
                    :default_url => '/assets/users-placeholder-:style.png'
  has_one :quiz_session

  validates :username, :presence => true, :uniqueness => true, :length => 2..15
  validates :password, :presence => true,
                       :if => Proc.new { |user|
                                          user.new_record? ||
                                               user.password_required }
  validates :password, :length => 4..20, :confirmation => true,
                       :if => Proc.new { |user|
                                          user.password.present? }
  validates :password_confirmation, :presence => true,
                                    :if => Proc.new { |user|
                                                      user.password.present? }
  validates :fullname, :presence => true, :length => 2..80
  validates :email, :presence => true, :uniqueness => true,
                    :format => {
                      :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
                    }
  validates_attachment :avatar,
                       :size => {:less_than => Setting.upload.image_limit}

  self.per_page = 20

  before_save :encrypt_password
  before_create :reset_authentication_token

  def authenticate(password)
    # User.find_by_username(self.username)
    if self.password_digest == hash_secret(password)
      return self
    end
  end

  def teacher?(course_id)
    self.teaching_courses.where(:id => course_id).present?
  end

  def student?(course_id)
    self.learning_courses.where(:id => course_id).present?
  end

  def reset_password!
    self.reset_password_token = SecureRandom.urlsafe_base64
    save!
    UserMailer.reset_password(self.id).deliver
    self.reset_password_token
  end

  def avatar_errors?
    self.errors[:avatar_file_size].present? ||
    self.errors[:avatar_content_type].present?
  end

  def brief_about
    self.about.gsub(/<\/?.*?>/, "").gsub(/&nbsp;/i,"") if self.about
  end

  def display_name
    self.fullname.blank? ? self.username : "#{self.fullname} - #{self.username}"
  end

  def reset_authentication_token
    random_key = SecureRandom.urlsafe_base64
    while User.where(:authentication_token => random_key).present?
      random_key = SecureRandom.urlsafe_base64
    end
    self.authentication_token = random_key
  end

  def current_quiz_session(quiz)
    self.quiz_session if self.quiz_session.quiz == quiz
  end

  def to_param
    return id if self.username.blank?
    "#{id}-#{self.username.downcase.gsub(/[^a-zA-Z0-9]+/, '-')
                                   .gsub(/-{2,}/, '-')
                                   .gsub(/^-|-$/, '')}"
  end

  protected
  def image_path
    "#{Rails.root}/public#{self.image_url}"
  end

  def image_url
    '/system/:class/:attachment/:id/:style/:basename.:extension'
  end

  def hash_secret(password)
     Digest::MD5.hexdigest(password)
  end

  def encrypt_password
    if self.password.present?
      self.password_digest = hash_secret(password)
    end
  end
end
