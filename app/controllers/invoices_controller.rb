class InvoicesController < ApplicationController
  before_action :authenticate_user!

  def index
    Time.zone = "Asia/Jakarta"
    page = (params[:page] || 1).to_i
    filter = Invoice.where(user: current_user).order(pick_up_at: :desc)

    if params[:driver_name]
      filter = filter.where(driver_name: params[:driver_name])
    end

    @invoices = filter.page(page)
  end

  def refresh
    flash[:info] = "Processing Data From Gmail. Please Close this tab and reopen in a minute"
    UserRefreshJob.perform_later(current_user.id)
    redirect_to '/'
  end
end
