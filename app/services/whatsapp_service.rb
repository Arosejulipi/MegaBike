# frozen_string_literal: true

require "net/http"

class WhatsappService
  class << self
    def configured?
      ENV["TWILIO_ACCOUNT_SID"].present? &&
        ENV["TWILIO_AUTH_TOKEN"].present? &&
        ENV["TWILIO_WHATSAPP_FROM"].present?
    end

    def send_message(to:, body:)
      return false unless configured?
      return false if body.blank?

      recipient = normalize_number(to)
      sender = normalize_number(ENV["TWILIO_WHATSAPP_FROM"])
      return false if recipient.blank? || sender.blank?

      uri = URI("https://api.twilio.com/2010-04-01/Accounts/#{ENV.fetch('TWILIO_ACCOUNT_SID')}/Messages.json")
      request = Net::HTTP::Post.new(uri)
      request.basic_auth(ENV.fetch("TWILIO_ACCOUNT_SID"), ENV.fetch("TWILIO_AUTH_TOKEN"))
      request["Content-Type"] = "application/x-www-form-urlencoded"
      request.body = URI.encode_www_form("To" => recipient, "From" => sender, "Body" => body)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
      success = response.code.to_i.between?(200, 299)

      Rails.logger.error("WhatsappService error #{response.code}: #{response.body}") unless success
      success
    rescue StandardError => e
      Rails.logger.error("WhatsappService exception #{e.class}: #{e.message}")
      false
    end

    def normalize_number(raw_number)
      return nil if raw_number.blank?

      value = raw_number.to_s.strip
      return value if value.start_with?("whatsapp:+")

      digits = value.gsub(/[^\d+]/, "")
      return nil if digits.blank?

      digits = "+#{digits}" unless digits.start_with?("+")
      "whatsapp:#{digits}"
    end
  end
end
