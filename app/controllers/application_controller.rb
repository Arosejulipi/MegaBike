# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :admin?, :support_whatsapp_url

  # Temporary production helper to capture unhandled exceptions into a public file
  # Enable by setting EXPOSE_ERRORS_PUBLIC=1 in Render environment variables.
  if ENV["EXPOSE_ERRORS_PUBLIC"] == "1"
    rescue_from StandardError do |exception|
      begin
        log_path = Rails.root.join("public", "last_error.log")
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
    redirect_to login_path, alert: "Tenes que iniciar sesion para continuar."
  end

  def require_admin
    return if admin?
    redirect_to root_path, alert: "No tenes permisos para acceder."
  end

  def support_whatsapp_url
    url = ENV["WHATSAPP_SUPPORT_URL"].to_s.strip
    return url unless url == ""

    # Default support phone (requested): +54 9 341 213 0596
    phone = ENV["WHATSAPP_SUPPORT_PHONE"].to_s.strip
    phone = "+5493412130596" if phone == ""
    return nil if phone == ""

    digits = phone.gsub(/[^\d]/, "")
    return nil if digits == ""

    msg = ENV["WHATSAPP_SUPPORT_MESSAGE"].to_s.strip
    msg = "Hola! Necesito ayuda con Mega Bike." if msg == ""

    require "cgi"
    "https://wa.me/#{digits}?text=#{CGI.escape(msg)}"
  rescue StandardError
    nil
  end
end
