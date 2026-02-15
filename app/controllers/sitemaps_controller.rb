class SitemapsController < ApplicationController
  layout false

  def show
    @posts = Post.visible.latest

    respond_to do |format|
      format.xml
    end
  end
end
