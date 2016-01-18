require 'base64'
require 'rc4'
require 'cgi'

class PackagesController < ApplicationController
  before_filter :load_collection, :except => [:index, :new, :create]
  def show
  end

  def pay_online
    @account_id = Setting.ebs.account_id
    @payment_mode = Rails.env.production? ? 'LIVE' : 'TEST'
    @reference_number = "#{@collection.id}_#{current_user.id}_#{Time.now.to_i}"
  end

  def payment_complete
    encrypted_response = params[:DR]
    encrypted_response.gsub!(/ /, '+')
    decoded_response = Base64.decode64(encrypted_response)
    payment_response = RC4.new(Setting.ebs.secret).encrypt(decoded_response)
    payment_response_query = CGI::parse payment_response
    if payment_response_query['ResponseCode'].first == '0'
      @collection.courses.each do |course|
        course.add_student(current_user)
      end
      flash.now[:notice] = payment_response_query['ResponseMessage'].first
      @success = true
    else
      flash.now[:error] = payment_response_query['ResponseMessage'].first
    end
  end

  def enroll
    enroll_student
  end

  def dropout
    @collection.courses.each do |course|
      course.students.delete(current_user)
    end
    flash[:notice] = t('courses.dropped_out')
  end

  def enroll_student
    @success = true
    @collection.courses.each do |course|
      course.add_student(current_user)
    end
    flash[:notice] = t('courses.enrolled')
  end

  def load_collection
    @collection = Collection.find(params[:id])
  end
end
