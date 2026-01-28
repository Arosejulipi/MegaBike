# frozen_string_literal: true

class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:email].to_s.downcase.strip)
    if user&.authenticate(params[:password].to_s)
      session[:user_id] = user.id
      redirect_to root_path, notice: "¡Bienvenida/o, #{user.name}!"
    else
      flash.now[:alert] = "Email o contraseña incorrectos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Sesión cerrada."
  end
end
