# frozen_string_literal: true

class OwnerMailer < ApplicationMailer
  ADMIN_EMAILS = (ENV["ADMIN_EMAILS"] || ENV["MEGABIKE_OWNER_EMAIL"] || "duenios@megabike.com")

  def appointment_request(appointment)
    @appointment = appointment
    recipients = ADMIN_EMAILS.split(/,\s*/)

    if ENV['SENDGRID_API_KEY'].present?
      html = render_to_string(template: 'owner_mailer/appointment_request', formats: [:html]) rescue nil
      text = render_to_string(template: 'owner_mailer/appointment_request', formats: [:text]) rescue ActionController::Base.helpers.strip_tags(html.to_s)
      SendgridService.send_email(to: recipients, subject: "Nuevo turno de servicio - Mega Bike", html_body: html, text_body: text, from: (ENV['DEFAULT_FROM_EMAIL'] || default_params[:from]))
    else
      mail(to: recipients, subject: "Nuevo turno de servicio - Mega Bike")
    end
  end

  def appointment_confirmation(appointment)
    @appointment = appointment
    if ENV['SENDGRID_API_KEY'].present?
      html = render_to_string(template: 'owner_mailer/appointment_confirmation', formats: [:html]) rescue nil
      text = render_to_string(template: 'owner_mailer/appointment_confirmation', formats: [:text]) rescue ActionController::Base.helpers.strip_tags(html.to_s)
      SendgridService.send_email(to: @appointment.email, subject: "Confirmación de turno - Mega Bike", html_body: html, text_body: text, from: (ENV['DEFAULT_FROM_EMAIL'] || default_params[:from]))
    else
      mail(to: @appointment.email, subject: "Confirmación de turno - Mega Bike")
    end
  end

  def custom_quote_request(custom_quote)
    @custom_quote = custom_quote
    recipients = ADMIN_EMAILS.split(/,\s*/)
    if ENV['SENDGRID_API_KEY'].present?
      html = render_to_string(template: 'owner_mailer/custom_quote_request', formats: [:html]) rescue nil
      text = render_to_string(template: 'owner_mailer/custom_quote_request', formats: [:text]) rescue ActionController::Base.helpers.strip_tags(html.to_s)
      SendgridService.send_email(to: recipients, subject: "Nueva solicitud de bici personalizada - Mega Bike", html_body: html, text_body: text, from: (ENV['DEFAULT_FROM_EMAIL'] || 'no-reply@megabike.local'))
    else
      mail(to: recipients, subject: "Nueva solicitud de bici personalizada - Mega Bike")
    end
  end
end
