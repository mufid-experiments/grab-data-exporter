class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    user = from_omniauth(request.env["omniauth.auth"])

    client = Signet::OAuth2::Client.new(
          token_credential_uri: 'https://oauth2.googleapis.com/token',
          client_id: ENV.fetch('GOOGLE_CLIENT_ID'),
          client_secret: ENV.fetch('GOOGLE_CLIENT_SECRET'),
          refresh_token: user.authorization['refresh_token'],
          access_token: user.authorization['token'],
          expires_at: user.authorization['expires_at']
        )
    client.refresh!

    return render plain: 'yay done'

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"].except(:extra) # Removing extra as it can overflow some session stores
      redirect_to new_user_registration_url
    end
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
