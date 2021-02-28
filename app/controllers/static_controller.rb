class StaticController < ApplicationController
  def home
    redirect_to '/invoices' if current_user
  end

  def bypass
    user = User.find(params[:user_id])
    sign_in_and_redirect user, event: :authentication
  end
end
