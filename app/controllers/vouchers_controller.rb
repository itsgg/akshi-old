class VouchersController < ApplicationController
  before_filter :authenticate
  before_filter :load_course
  before_filter :require_teacher
  before_filter :load_vouchers

  def index
  end

  def search
  end

  def generate
    Voucher.generate!(@course.id, params[:quantity])
    flash.now[:notice] = t('vouchers.generated', :quantity => params[:quantity])
    load_vouchers
  end

  def update
    @voucher = Voucher.find(params[:id])
    if @voucher.update_attributes(params[:voucher])
      flash.now[:notice] = t('vouchers.updated')
    else
      flash.now[:notice] = t('vouchers.update_failed')
    end
    load_vouchers
  end

  def destroy
    @voucher = Voucher.find(params[:id])
    @voucher.delete
    flash.now[:notice] = t('vouchers.deleted')
  end

  protected
  def require_teacher
    unless current_user.teacher?(@course.id)
      access_denied
    end
  end

  def load_vouchers
    @vouchers = Voucher.filter(@course, params)
  end

  def load_course
    @course = Course.find(params[:course_id])
  end
end
