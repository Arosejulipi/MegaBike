# frozen_string_literal: true

class OwnerMailer < ApplicationMailer
  OWNER_EMAIL = ENV.fetch("MEGABIKE_OWNER_EMAIL", "duenios@megabike.com")

  def appointment_request(appointment)
    @appointment = appointment
    mail(to: OWNER_EMAIL, subject: "Nuevo turno de servicio - Mega Bike")
  end

  def custom_quote_request(custom_quote)
    @custom_quote = custom_quote
    mail(to: OWNER_EMAIL, subject: "Nueva solicitud de bici personalizada - Mega Bike")
  end
end
