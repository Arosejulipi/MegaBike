# frozen_string_literal: true

require "net/http"
require "json"

# Lightweight email gateway over HTTPS.
# Intended for platforms where SMTP is blocked (e.g., Render free tier).
#
# Recommended backend: Google Apps Script Web App (uses GmailApp.sendEmail).
class EmailWebhookService
  class << self
    def configured?
      url = ENV["EMAIL_WEBHOOK_URL"].to_s
      !url.empty?
    end

    def send_email(to:, subject:, html_body:, text_body: nil, from: nil)
      return false unless configured?

      uri = URI(ENV.fetch("EMAIL_WEBHOOK_URL"))
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"

      token = ENV["EMAIL_WEBHOOK_TOKEN"].to_s
      token = nil if token.empty?
      request["Authorization"] = "Bearer #{token}" if token

      payload = {
        to: Array(to).join(","),
        subject: subject.to_s,
        html: html_body.to_s,
        text: text_body.to_s,
        from: from.to_s
      }
      request.body = JSON.generate(payload)

      response = Net::HTTP.start(
        uri.hostname,
        uri.port,
        use_ssl: uri.scheme == "https",
        open_timeout: (ENV["EMAIL_WEBHOOK_OPEN_TIMEOUT"].to_s.empty? ? 5 : ENV["EMAIL_WEBHOOK_OPEN_TIMEOUT"].to_i),
        read_timeout: (ENV["EMAIL_WEBHOOK_READ_TIMEOUT"].to_s.empty? ? 20 : ENV["EMAIL_WEBHOOK_READ_TIMEOUT"].to_i)
      ) { |http| http.request(request) }

      success = response.code.to_i.between?(200, 299)
      Rails.logger.error("EmailWebhookService error #{response.code}: #{response.body}") unless success
      success
    rescue StandardError => e
      Rails.logger.error("EmailWebhookService exception #{e.class}: #{e.message}")
      false
    end
  end
end
