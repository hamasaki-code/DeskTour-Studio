class Admin::BaseController < ApplicationController
  before_action :authenticate_admin!

  private

  def authenticate_admin!
    username = ENV["ADMIN_USERNAME"].to_s
    password = ENV["ADMIN_PASSWORD"].to_s

    if username.blank? || password.blank?
      head :forbidden
      return
    end

    authenticate_or_request_with_http_basic("DeskTour Admin") do |provided_username, provided_password|
      ActiveSupport::SecurityUtils.secure_compare(provided_username, username) &
        ActiveSupport::SecurityUtils.secure_compare(provided_password, password)
    end
  end
end
