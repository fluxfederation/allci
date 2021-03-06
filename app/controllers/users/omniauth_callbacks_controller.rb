class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  protect_from_forgery :except => [:developer]

  def developer
    @user = User.from_omniauth(request.env["omniauth.auth"])
    sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
  end

  def google_oauth2
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
        sign_in_and_redirect @user, event: :authentication
      end
  end

  def failure
    redirect_to root_path
  end
end

