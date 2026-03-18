class SessionsController < ApplicationController
  def create
    @login_username = params[:username].to_s
    user = User.find_by(username: User.normalize_username_value(@login_username))

    if user&.authenticate(params[:password].to_s)
      reset_session
      session[:authenticated_user_id] = user.id
      redirect_to user_path(user), notice: t("auth.flash.logged_in")
    else
      flash.now[:alert] = t("auth.flash.invalid_credentials")
      render "pages/login", status: :unprocessable_entity
    end
  end

  def destroy
    clear_owner_session!
    redirect_to root_path, notice: t("editorial.header.logout_notice")
  end
end
