class UserRefreshJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    User.find(user_id).email_id_each do |email_id|
      EmailRefreshJob.perform_later(user_id, email_id)
    end
  end
end
