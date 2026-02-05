# frozen_string_literal: true

class MailerDeliveryService
  class << self
    def deliver(message_delivery)
      return deliver_via_webhook(message_delivery) if EmailWebhookService.configured?
      message_delivery.deliver_now
      true
    rescue StandardError => e
      Rails.logger.error("MailerDeliveryService failed: #{e.class}: #{e.message}")
      false
    end

    private

    def deliver_via_webhook(message_delivery)
      msg = message_delivery.message
      html = msg.body.to_s
      text = html.to_s.gsub(/<[^>]*>/, " ").gsub(/\s+/, " ").strip

      EmailWebhookService.send_email(
        to: msg.to,
        subject: msg.subject,
        html_body: html,
        text_body: text,
        from: msg.from&.first
      )
    end
  end
end

