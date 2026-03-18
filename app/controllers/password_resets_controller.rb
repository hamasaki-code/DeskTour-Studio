class PasswordResetsController < ApplicationController
  before_action :set_reset_user, only: %i[edit update]

  def new
    @reset_username = params[:username].to_s
    @reset_email = params[:email].to_s
  end

  def create
    @reset_username = params[:username].to_s
    @reset_email = params[:email].to_s.strip.downcase
    user = User.find_by(username: User.normalize_username_value(@reset_username))

    if user&.email.present? && user.email.casecmp?(@reset_email)
      redirect_to edit_password_reset_path(token: user.signed_id(purpose: "password_reset", expires_in: 20.minutes)),
                  notice: t("auth.reset.verified")
    else
      flash.now[:alert] = t("auth.reset.not_found")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @reset_user.update(password_reset_params)
      reset_session
      session[:authenticated_user_id] = @reset_user.id
      redirect_to user_path(@reset_user), notice: t("auth.reset.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_reset_user
    @token = params[:token].to_s
    @reset_user = User.find_signed(@token, purpose: "password_reset")
    return if @reset_user

    redirect_to password_reset_path, alert: t("auth.reset.invalid_token")
  end

  def password_reset_params
    params.permit(:password, :password_confirmation)
  end
end
