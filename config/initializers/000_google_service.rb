class GoogleCreds
  def self.client_id
    Rails.application.credentials.google_client_id ||ENV.fetch('GOOGLE_CLIENT_ID')
  end

  def self.client_secret
    Rails.application.credentials.google_client_secret || ENV.fetch('GOOGLE_CLIENT_SECRET')
  end
end