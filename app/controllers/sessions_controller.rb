class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(request.env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to profile_path, notice: "Signed in as #{user.name}."
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "Signed out."
  end

  def failure
    redirect_to root_path, alert: "Google sign-in failed. Please try again."
  end
end
