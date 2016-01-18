class SitesController < ApplicationController
  before_filter :admin_authenticate

  def update
    site = Site.instance
    if site.update_attributes(params[:site])
      flash[:notice] = t('site.updated')
    else
      flash[:notice] = t('site.update_failed')
    end
  end
end
