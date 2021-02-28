class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    user = from_omniauth(request.env["omniauth.auth"])

    client = Signet::OAuth2::Client.new(
          token_credential_uri: 'https://oauth2.googleapis.com/token',
          client_id: GoogleCreds.client_id,
          client_secret: GoogleCreds.client_secret,
          refresh_token: user.authorization['refresh_token'],
          access_token: user.authorization['token'],
          expires_at: user.authorization['expires_at']
        )
    client.refresh!

    sign_in_and_redirect user, event: :authentication
  end

  def failure
    redirect_to root_path
  end

  def from_omniauth(env)
    user = User.create_or_find_by(email: env.info.email)

    user.update(authorization: env.credentials)
    user.save

    user
  end
end
