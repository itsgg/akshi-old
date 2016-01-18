class AdminController < ApplicationController
  before_filter :admin_authenticate
end
