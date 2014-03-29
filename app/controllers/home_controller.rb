class HomeController < ApplicationController
  layout 'main'

  def index
    if user_signed_in?
      redirect_to user_home_path
    end
  end
end
