class EmailRefreshJob < ApplicationJob
  queue_as :default

  def perform(user_id, email_id)
    user = User.find(user_id)
    gmail_email = user.find_email(email_id)
    Invoice.from(gmail_email: gmail_email, user: user)
  end
end
