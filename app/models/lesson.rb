# == Schema Information
#
# Table name: lessons
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  course_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  upload_file_name    :string(255)
#  upload_content_type :string(255)
#  upload_file_size    :integer
#  upload_updated_at   :datetime
#  position            :integer
#  content             :text(2147483647)
#  published           :boolean          default(FALSE)
#  subject_id          :integer
#

class Lesson < ActiveRecord::Base
  DOCUMENT_TYPE = ['.pdf', '.doc', '.ppt', '.xls', '.docx', '.pptx', '.xlsx',
                   '.odt', '.ods', '.odp']
  VIDEO_TYPE = ['.avi', '.mp4', '.mov', '.flv', '.m4v', '.3gp']
  AUDIO_TYPE = ['.mp3', '.wav', '.m4a']
  ANIMATED_TYPE = ['.gif']
  MEDIA_TYPE = VIDEO_TYPE + AUDIO_TYPE
  FILTER_TYPE = ["All", "Media", "Document"]

  belongs_to :course
  belongs_to :subject
  has_many :schedules

  attr_accessible :name, :upload, :content, :published, :position, :subject_id

  scope :published, :conditions => {:published => true}

  acts_as_readable :on => :created_at

  validates :name, :presence => true, :length => 4..80
  validates :course_id, :presence => true
  validates_attachment :upload,
                       :size => {:less_than => Setting.upload.lesson_limit}

  has_attached_file :upload, :path => :upload_path, :url => :upload_url
  after_post_process :convert

  default_scope :order => 'lessons.position ASC, lessons.created_at DESC'

  self.per_page = 10

  Paperclip.interpolates :normalized_file_name do |attachment, style|
    attachment.instance.normalized_file_name
  end

  def normalized_file_name
    extname = File.extname(self.upload_file_name)
    basename = self.upload_file_name.chomp(extname)
    "#{self.id}-#{basename.gsub(/[^0-9A-Za-z]/, '_')}#{extname}"
  end

  def delete_attachment!
    Resque.enqueue AttachmentDeleter, self.upload.path
    self.upload.clear && self.save
  end

  def self.filter(filter = 'All')
    if filter.blank? || filter == 'All'
      self.scoped
    else
      query = []
      self.const_get("#{filter.upcase}_TYPE").each do |file_type|
        query <<= ["upload_file_name like '%\\#{file_type}'"]
      end
      self.scoped.where(query.join(' or '))
    end
  end

  def upload_type
    return nil if self.upload_file_name.blank?
    extname = File.extname(normalized_file_name)
    return 'document' if DOCUMENT_TYPE.include?(extname)
    return 'animate' if ANIMATED_TYPE.include?(extname)
    return 'media' if MEDIA_TYPE.include?(extname)
    return 'file'
  end

  def conversion_complete?
    file_path = self.upload.try(:path)
    return if file_path.blank?
    basename = file_path.chomp(File.extname(file_path))
    File.exists?("#{basename}.converted") || self.upload_type == 'file'
  end

  def self.order!(ids)
    if ids.present?
      update_all(
        ['position = FIND_IN_SET(id, ?)', ids.join(',')],
        {:id => ids})
    end
  end

  def processed_uploads
    if upload_content_type != "image/gif"
      if upload.present?
        path = upload.path
        url = upload.url
        Dir.glob("#{path.chomp(File.extname(path))}*_[0-9]*.png").map do |file|
          "#{File.dirname(url)}/#{File.basename(file)}"
        end.sort_by do |file|
          file.split('_').last.split('.').first.to_i
        end
      end
    else
      path = upload.path
      url = upload.url
      Dir.glob("#{path.chomp(File.extname(path))}*.gif").map do |file|
        "#{File.dirname(url)}/#{File.basename(file)}"
      end.sort_by do |file|
        file.split('_').last.split('.').first.to_i
      end
    end
  end
  
  protected
  def upload_path
    "#{Rails.root}/data/#{self.upload_url}"
  end

  def upload_url
    '/:class/:attachment/:id/:updated_at-:normalized_file_name'
  end

  def convert
    if self.upload_type != 'file'
      converter = Kernel.const_get("#{self.upload_type.capitalize}Converter")
      Resque.enqueue converter, self.upload.path
    end
  end
end
