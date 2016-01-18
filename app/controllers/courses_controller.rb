require 'base64'
require 'rc4'
require 'cgi'

class CoursesController < ApplicationController
  before_filter :authenticate, :except => [:index, :show, :users]
  before_filter :load_course, :except => [:index, :new, :create]
  before_filter :require_teacher, :only => [:update, :destroy]
  before_filter :require_login, :only => [:index]
  before_filter :require_published_for_student, :only => [:show]
  before_filter :admin_authenticate, :only => [:update_status]

  def index
    filtered_courses = Course.filter(current_user, params)
    @total_courses = filtered_courses.size
    @courses = filtered_courses.paginate :page => params[:page],
                                         :per_page => params[:per_page]
    @categories = Category.all
    @upcoming_classes = Schedule.active.upcoming.limit(3)
    @recent_posts = Post.limit(4)
    @root_collections = Collection.roots
    @current_collection = Collection.find_by_id(params[:collection])
    @featured_courses = @courses.featured if params[:type] != 'learn' && params[:type] != 'teach'
  end

  def new
    @course = Course.new
  end

  def update
    # Set course status
    case params[:course][:published]
    when '1'
      params[:course][:status] = 'review' unless @course.status == 'published'
    when '0'
      params[:course][:status] = 'new'
    end

    # Set the features
    if params[:course][:features].present?
      feature_array = params[:course][:features].map do |key, value|
        if value == '1'
          key
        end
      end.reject(&:blank?)
      params[:course][:features] = feature_array
    end

    @old_cover = @course.cover(:large)
    if @course.update_attributes(params[:course])
      @success = true
      flash[:notice] = t('courses.updated')
    else
      flash.now[:error] = t('courses.update_failed')
    end
  end

  def show
  end

  def create
    @course = Course.new(params[:course])
    if @course.save
      @success = true
      @course.add_teacher(current_user)
      flash[:notice] = t('courses.created')
    else
      flash.now[:error] = t('courses.create_failed')
    end
  end

  def enroll
    if current_user.admin?
      enroll_student
    else
      if @course.published?
        enroll_student
      else
        flash[:error] = t('courses.not_published')
      end
    end
  end

  def enroll_by_voucher
    if @course.published?
      if @course.vouchers.find_by_code(params[:voucher_code]).try(:status_valid?)
        enroll_student
      else
        flash.now[:error] = t('courses.invalid_voucher_code')
      end
    else
      flash.now[:error] = t('courses.not_published')
    end
  end

  def dropout
    @course.students.delete(current_user)
    flash[:notice] = t('courses.dropped_out')
  end

  def pay_online
    @account_id = Setting.ebs.account_id
    @payment_mode = Rails.env.production? ? 'LIVE' : 'TEST'
    @reference_number = "#{@course.id}_#{current_user.id}_#{Time.now.to_i}"
  end

  def payment_complete
    encrypted_response = params[:DR]
    encrypted_response.gsub!(/ /, '+')
    decoded_response = Base64.decode64(encrypted_response)
    payment_response = RC4.new(Setting.ebs.secret).encrypt(decoded_response)
    payment_response_query = CGI::parse payment_response
    if payment_response_query['ResponseCode'].first == '0'
      @course.add_student(current_user)
      flash.now[:notice] = payment_response_query['ResponseMessage'].first
      @success = true
    else
      flash.now[:error] = payment_response_query['ResponseMessage'].first
    end
  end

  def destroy
    @course.delete
    flash[:notice] = t('courses.deleted')
  end

  def users
    @users = @course.users.paginate :page => params[:page],
                                    :per_page => params[:per_page]
  end

  def update_status
    case params[:status]
    when 'publish'
      @course.publish!
      flash.now[:notice] =  t('courses.published')
    when 'reject'
      @course.reject!
      flash.now[:notice] =  t('courses.rejected')
    end
    @courses = Course.review.paginate :page => params[:page],
                                      :per_page => params[:per_page]
  end

  protected
  def enroll_student
    @success = true
    @course.add_student(current_user)
    flash[:notice] = t('courses.enrolled')
  end

  def require_published_for_student
    return true if current_user.try(:admin?)
    unless current_user.try(:teacher?, @course.id)
      unless @course.published?
        access_denied
      end
    end
  end

  def load_course
    @course = Course.find(params[:id])
  end

  def require_teacher
    unless current_user.teacher?(@course.id)
      access_denied
    end
  end

  def require_login
    if !logged_in? && params[:type].present? && params[:type] != 'home'
      authenticate
    end
  end
end
