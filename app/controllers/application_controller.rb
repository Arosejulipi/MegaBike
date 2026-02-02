# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :admin?

  # Temporary production helper to capture unhandled exceptions into a public file
  # Enable by setting EXPOSE_ERRORS_PUBLIC=1 in Render environment variables.
  if ENV['EXPOSE_ERRORS_PUBLIC'] == '1'
    rescue_from StandardError do |exception|
      begin
        log_path = Rails.root.join('public', 'last_error.log')
        content = ["Exception: #{exception.class}: #{exception.message}", *exception.backtrace].join("\n")
        File.write(log_path, content)
      rescue => write_err
        Rails.logger.error "Failed to write public error log: ", write_err
      end
      raise exception
    end
  end

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
