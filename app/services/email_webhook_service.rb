# frozen_string_literal: true

require "net/http"
require "json"

# Lightweight email gateway over HTTPS.
# Intended for platforms where SMTP is blocked (e.g., Render free tier).
#
# Recommended backend: Google Apps Script Web App (uses GmailApp.sendEmail).
class EmailWebhookService
  MAX_REDIRECTS = 5

  class << self
    def configured?
      url = ENV["EMAIL_WEBHOOK_URL"].to_s
      !url.empty?
    end

    def send_email(to:, subject:, html_body:, text_body: nil, from: nil)
      return false unless configured?

      result = request_email(to: to, subject: subject, html_body: html_body, text_body: text_body, from: from)
      result[:success]
    end

    # Returns a hash: { success: true/false, code: Integer, body: String }
    def request_email(to:, subject:, html_body:, text_body: nil, from: nil)
      payload = {
        to: Array(to).join(","),
        subject: subject.to_s,
        html: html_body.to_s,
        text: text_body.to_s,
        from: from.to_s
      }

      token = ENV["EMAIL_WEBHOOK_TOKEN"].to_s
      token = nil if token.empty?

      uri = URI(ENV.fetch("EMAIL_WEBHOOK_URL"))
      response = post_json_with_redirects(uri, payload, token: token)

      code = response.code.to_i
      body = response.body.to_s
      success = code.between?(200, 299)
      Rails.logger.error("EmailWebhookService error #{code}: #{body}") unless success
      { success: success, code: code, body: body }
    rescue StandardError => e
      Rails.logger.error("EmailWebhookService exception #{e.class}: #{e.message}")
      { success: false, code: 0, body: "#{e.class}: #{e.message}" }
    end

    private

    def post_json_with_redirects(uri, payload, token:)
      redirects = 0
      current_uri = uri

      loop do
        raise "EMAIL_WEBHOOK_URL must be https" unless current_uri.scheme == "https"

        request = Net::HTTP::Post.new(current_uri)
        request["Content-Type"] = "application/json"
        request["Authorization"] = "Bearer #{token}" if token
        request.body = JSON.generate(payload)

        response = Net::HTTP.start(
          current_uri.hostname,
          current_uri.port,
          use_ssl: true,
          open_timeout: (ENV["EMAIL_WEBHOOK_OPEN_TIMEOUT"].to_s.empty? ? 5 : ENV["EMAIL_WEBHOOK_OPEN_TIMEOUT"].to_i),
          read_timeout: (ENV["EMAIL_WEBHOOK_READ_TIMEOUT"].to_s.empty? ? 20 : ENV["EMAIL_WEBHOOK_READ_TIMEOUT"].to_i)
        ) { |http| http.request(request) }

        return response unless response.is_a?(Net::HTTPRedirection)

        location = response["location"].to_s
        return response if location.empty?

        redirects += 1
        return response if redirects > MAX_REDIRECTS

        current_uri = URI.join(current_uri, location)
      end
    end
  end
end
