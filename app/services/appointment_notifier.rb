# frozen_string_literal: true

class AppointmentNotifier
  OWNER_WHATSAPP_TO = (ENV["ADMIN_WHATSAPP_TO"] || ENV["MEGABIKE_WHATSAPP_TO"] || "").freeze

  def self.notify(appointment)
    new(appointment).notify
  end

  def initialize(appointment)
    @appointment = appointment
  end

  def notify
    notify_owner_by_email
    notify_client_by_email
    notify_owner_by_whatsapp
    notify_client_by_whatsapp
  end

  private

  def notify_owner_by_email
    MailerDeliveryService.deliver(OwnerMailer.appointment_request(@appointment))
  rescue StandardError => e
    Rails.logger.error("AppointmentNotifier owner email failed: #{e.class}: #{e.message}")
  end

  def notify_client_by_email
    MailerDeliveryService.deliver(OwnerMailer.appointment_confirmation(@appointment))
  rescue StandardError => e
    Rails.logger.error("AppointmentNotifier client email failed: #{e.class}: #{e.message}")
  end

  def notify_owner_by_whatsapp
    owner_numbers.each do |number|
      WhatsappService.send_message(to: number, body: owner_message)
    end
  rescue StandardError => e
    Rails.logger.error("AppointmentNotifier owner whatsapp failed: #{e.class}: #{e.message}")
  end

  def notify_client_by_whatsapp
    return if @appointment.phone.blank?

    WhatsappService.send_message(to: @appointment.phone, body: client_message)
  rescue StandardError => e
    Rails.logger.error("AppointmentNotifier client whatsapp failed: #{e.class}: #{e.message}")
  end

  def owner_numbers
    OWNER_WHATSAPP_TO.split(/,\s*/).reject(&:blank?)
  end

  def owner_message
    [
      "Nuevo turno en Mega Bike",
      "Cliente: #{@appointment.full_name}",
      "Email: #{@appointment.email}",
      "Telefono: #{@appointment.phone.presence || 'sin telefono'}",
      "Servicio: #{@appointment.service_type}",
      "Fecha: #{@appointment.preferred_date}",
      "Hora: #{@appointment.preferred_time}",
      "Notas: #{@appointment.notes.presence || 'sin notas'}"
    ].join("\n")
  end

  def client_message
    [
      "Hola #{@appointment.full_name}, recibimos tu turno en Mega Bike.",
      "Servicio: #{@appointment.service_type}",
      "Fecha solicitada: #{@appointment.preferred_date}",
      "Hora solicitada: #{@appointment.preferred_time}",
      "Te vamos a confirmar el horario final a la brevedad."
    ].join("\n")
  end
end
