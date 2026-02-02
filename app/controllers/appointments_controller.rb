# frozen_string_literal: true

class AppointmentsController < ApplicationController
  def new
    @appointment = Appointment.new
  end

  def create
    @appointment = Appointment.new(appointment_params)
    if logged_in?
      @appointment.full_name = current_user.name if @appointment.full_name.blank?
      @appointment.email = current_user.email if @appointment.email.blank?
    end

    if @appointment.save
      OwnerMailer.appointment_request(@appointment).deliver_later
      OwnerMailer.appointment_confirmation(@appointment).deliver_later
      redirect_to root_path, notice: "Listo 🙌 Te agendamos el turno y avisamos a Mega Bike."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def appointment_params
    params.require(:appointment).permit(:full_name, :email, :phone, :service_type, :preferred_date, :preferred_time, :notes)
  end
end
