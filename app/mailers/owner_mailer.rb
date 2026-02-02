# frozen_string_literal: true

class OwnerMailer < ApplicationMailer
  ADMIN_EMAILS = (ENV["ADMIN_EMAILS"] || ENV["MEGABIKE_OWNER_EMAIL"] || "duenios@megabike.com")

  def appointment_request(appointment)
    @appointment = appointment
    recipients = ADMIN_EMAILS.split(/,\s*/)
    mail(to: recipients, subject: "Nuevo turno de servicio - Mega Bike")
  end

  def appointment_confirmation(appointment)
    @appointment = appointment
    mail(to: @appointment.email, subject: "Confirmación de turno - Mega Bike")
  end

  def custom_quote_request(custom_quote)
    @custom_quote = custom_quote
    mail(to: OWNER_EMAIL, subject: "Nueva solicitud de bici personalizada - Mega Bike")
  end
end
