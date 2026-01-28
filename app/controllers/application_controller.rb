# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :admin?

  private

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def admin?
    logged_in? && current_user.admin?
  end

  def require_login
    return if logged_in?
    redirect_to login_path, alert: "Tenés que iniciar sesión para continuar."
  end

  def require_admin
    return if admin?
    redirect_to root_path, alert: "No tenés permisos para acceder."
  end
end
