# == Schema Information
#
# Table name: courses
#
#  id                          :integer          not null, primary key
#  name                        :string(255)
#  description                 :text(2147483647)
#  category_id                 :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  cover_file_name             :string(255)
#  cover_content_type          :string(255)
#  cover_file_size             :integer
#  cover_updated_at            :datetime
#  average_score               :float            default(0.0), not null
#  status                      :string(255)      default("new")
#  amount                      :float            default(0.0)
#  currency                    :string(255)      default("INR")
#  paid                        :boolean          default(FALSE)
#  offline_payment_instruction :text
#  features                    :text
#  featured                    :boolean          default(FALSE)
#

class Course < ActiveRecord::Base
  CURRENCY = ['Rs', 'USD', 'SGD', 'EUR', 'JPY', 'GBP']
  FEATURES = ['announcement', 'lesson', 'discussion', 'quiz', 'live']

  attr_accessible :category_id, :description, :name, :published, :average_score,
                  :cover, :status, :amount, :currency, :paid,
                  :offline_payment_instruction, :features, :featured, :subject_id

  attr_accessor :published
  serialize :features, Array

  scope :published, :conditions => {:status => 'published'}
  scope :popular, :order => 'courses.average_score DESC, courses.created_at DESC'
  scope :review, :conditions => {:status => 'review'}
  scope :featured, :conditions => {:featured => true}
  scope :paid, :conditions => {:paid => true}
  
  belongs_to :category
  has_many :subjects
  has_many :roles, :dependent => :destroy
  has_many :users, :through => :roles
  has_many :students, :through => :roles, :source => :user,
                      :conditions => "roles.name = 'student'"
  has_many :teachers, :through => :roles, :source => :user,
                      :conditions => "roles.name = 'teacher'"
  has_many :lessons, :dependent => :destroy
  has_many :chats, :dependent => :destroy
  has_many :topics, :dependent => :destroy
  has_many :announcements, :dependent => :destroy
  has_many :quizzes, :dependent => :destroy
  has_many :ratings, :as => :ratable
  has_many :schedules
  has_many :vouchers
  has_and_belongs_to_many :collections

  has_attached_file :cover,
                    :styles => {:icon => '65x45#', :normal => '210x146#',
                                :large => '260x180#'},
                    :default_style => :normal, :url => :image_url,
                    :path => :image_path,
                    :default_url => '/assets/courses-placeholder-:style.png'

  validates :name, :presence => true, :length => 4..80
  validates :amount, :presence => true
  validates_attachment :cover,
                       :size => {:less_than => Setting.upload.image_limit}

  validates :currency, :inclusion => {:in => CURRENCY}, :if => :paid?
  validates :amount, :numericality => {:greater_than => 0}, :if => :paid?

  before_save :validate_features

  self.per_page = 9

  def published?
    self.status == 'published'
  end

  def review?
    self.status == 'review'
  end

  def publish!
    self.update_attribute(:status, 'published')
  end

  def reject!
    self.update_attribute(:status, 'rejected')
  end

  def review!
    self.update_attribute(:status, 'review')
  end

  def add_teacher(teacher)
    unless self.teachers.include?(teacher)
      self.roles << Role.new(:name => 'teacher', :user => teacher)
      reload
    end
  end

  def add_student(student)
    unless self.students.include?(student)
      self.roles << Role.new(:name => 'student', :user => student)
      reload
    end
  end

  def cover_errors?
    self.errors[:cover_file_size].present? ||
    self.errors[:cover_content_type].present?
  end

  def rated?(user_id)
    self.ratings.where(:owner_id => user_id).present?
  end

  def can_rate?(user_id)
    return if user_id.blank?
    user = User.find(user_id)
    is_student = user.try(:student?, self)
    is_student && !self.rated?(user_id)
  end

  def document_lessons
    self.lessons.select do |lesson|
       lesson.upload_type == 'document' || lesson.upload_type == "animate"
    end
  end

  def amount_description
    paid? ? "#{currency} #{amount.to_i}" : 'free'
  end

  def self.filter(user, params)
    courses = []
    case params[:type]
    when 'learn'
      courses = user.learning_courses.published.popular
    when 'teach'
      courses = user.teaching_courses.popular
    else
      courses = Course.published.popular
    end
    collection = Collection.find_by_id(params[:collection])
    if collection.present?
      courses = collection.courses.where(:id => courses.map(&:id))
    end
    if params[:category] == I18n.t('categories.none')
      courses = courses.where(:category_id => nil)
    end
    category = Category.find_by_name(params[:category])
    if category.present?
      courses = courses.where(:category_id => category.id)
    end
    if params[:q].try(:[], 'name_or_description_cont').present?
      courses = courses.search(params[:q]).result
    end
    courses
  end

  def feature_enabled?(feature)
    self.features.include?(feature) if self.features.present?
  end

  def as_json(options)
    {
      :name => self.name,
      :description => self.description,
      :cover_image => self.cover.url(:icon)
    }
  end

  def rate!
    if self.ratings.present?
      self.average_score = self.ratings.map(&:score).sum.to_f / self.ratings.size
    end
    self.save!
  end

  def to_param
    return id if self.name.blank?
    "#{id}-#{self.name.downcase.gsub(/[^a-zA-Z0-9]+/, '-')
                               .gsub(/-{2,}/, '-')
                               .gsub(/^-|-$/, '')}"
  end

  def list_subjects
    courses = ['All']
    unless self.subjects.blank? 
      courses << self.subjects.map(&:name)
    end
    courses.flatten
  end

  def list_of_subjects
    courses = []
    unless self.subjects.blank? 
      self.subjects.each do |subject|
        courses << [subject.name, subject.id]
      end
    end
    courses
  end

  protected
  def image_path
    "#{Rails.root}/public#{self.image_url}"
  end

  def image_url
    '/system/:class/:attachment/:id/:style/:basename.:extension'
  end

  def validate_features
    # Enable all features by default
    if self.new_record?
      self.features = Course::FEATURES
    end

    if self.features.blank?
      self.errors.add(:features, :blank)
      return false
    end

    if (self.features - Course::FEATURES).present?
      self.errors.add(:features, :invalid)
      return false
    end
  end
end
