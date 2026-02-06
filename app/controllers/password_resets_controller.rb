# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  def new; end

  def create
    email = params[:email].to_s.downcase.strip
    user = User.where("lower(email) = ?", email).first

    if user
      token = user.signed_id(purpose: :password_reset, expires_in: 2.hours)
      MailerDeliveryService.deliver(UserMailer.password_reset(user, token))
    end

    redirect_to login_path, notice: "Si el email existe, te enviamos un link para restablecer tu contraseña."
  end

  def edit
    @token = params[:token].to_s
    @user = User.find_signed!(@token, purpose: :password_reset)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_reset_path, alert: "El link de recuperacion es invalido o vencio. Pedi uno nuevo."
  end

  def update
    @token = params[:token].to_s
    @user = User.find_signed!(@token, purpose: :password_reset)

    if @user.update(password_params)
      redirect_to login_path, notice: "Listo! Ya podés ingresar con tu nueva contraseña."
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_reset_path, alert: "El link de recuperacion es invalido o vencio. Pedi uno nuevo."
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
