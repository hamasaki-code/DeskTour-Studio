class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update]
  before_action :require_user_owner!, only: %i[edit update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    raw_owner_token = SecureRandom.urlsafe_base64(32)
    @user.owner_token_digest = User.digest_owner_token(raw_owner_token)

    if @user.save
      store_user_owner_token(@user, raw_owner_token)
      redirect_to @user, notice: "プロフィールを作成しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @posts = @user.posts.visible.latest.includes(:items, desk_image_attachment: :blob)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "プロフィールを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def require_user_owner!
    return if user_owner?(@user)

    redirect_to user_path(@user), alert: "このプロフィールは本人のみ編集できます。"
  end

  def user_params
    params.require(:user).permit(:name, :bio)
  end
end
