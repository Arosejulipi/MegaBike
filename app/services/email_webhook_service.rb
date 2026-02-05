# frozen_string_literal: true

require "net/http"
require "json"
require "cgi"

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

    # Returns a hash:
    # { success: true/false, code: Integer, body: String, final_url: String, chain: [{url, code, location}] }
    def request_email(to:, subject:, html_body:, text_body: nil, from: nil)
      raw_method = ENV["EMAIL_WEBHOOK_METHOD"].to_s.strip.downcase
      method = raw_method.empty? ? "get" : raw_method

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
      result =
        if method == "post"
          post_json_with_redirects(uri, payload, token: token)
        else
          get_with_query(uri, payload, token: token)
        end

      response = result[:response]

      code = response.code.to_i
      body = response.body.to_s
      success = code.between?(200, 299)
      Rails.logger.error("EmailWebhookService error #{code}: #{body}") unless success
      {
        success: success,
        code: code,
        body: body,
        final_url: result[:final_url].to_s,
        chain: result[:chain],
        method: method
      }
    rescue StandardError => e
      Rails.logger.error("EmailWebhookService exception #{e.class}: #{e.message}")
      raw_method = ENV["EMAIL_WEBHOOK_METHOD"].to_s.strip.downcase
      method = raw_method.empty? ? "get" : raw_method
      { success: false, code: 0, body: "#{e.class}: #{e.message}", final_url: "", chain: [], method: method }
    end

    private

    def get_with_query(uri, payload, token:)
      current_uri = uri.dup
      chain = []

      # Prefer token as query param; headers in Apps Script can be flaky for doGet.
      query_hash = payload.dup
      query_hash[:token] = token if token

      current_uri.query = URI.encode_www_form(query_hash)

      response = Net::HTTP.start(
        current_uri.hostname,
        current_uri.port,
        use_ssl: current_uri.scheme == "https",
        open_timeout: (ENV["EMAIL_WEBHOOK_OPEN_TIMEOUT"].to_s.empty? ? 5 : ENV["EMAIL_WEBHOOK_OPEN_TIMEOUT"].to_i),
        read_timeout: (ENV["EMAIL_WEBHOOK_READ_TIMEOUT"].to_s.empty? ? 20 : ENV["EMAIL_WEBHOOK_READ_TIMEOUT"].to_i)
      ) do |http|
        http.get(current_uri.request_uri)
      end

      chain << { url: current_uri.to_s, code: response.code.to_i, location: response["location"].to_s }
      { response: response, final_url: current_uri.to_s, chain: chain }
    end

    def post_json_with_redirects(uri, payload, token:)
      redirects = 0
      current_uri = uri
      chain = []

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

        location = response["location"].to_s
        chain << { url: current_uri.to_s, code: response.code.to_i, location: location }

        unless response.is_a?(Net::HTTPRedirection)
          return { response: response, final_url: current_uri.to_s, chain: chain }
        end

        return { response: response, final_url: current_uri.to_s, chain: chain } if location.empty?

        redirects += 1
        return { response: response, final_url: current_uri.to_s, chain: chain } if redirects > MAX_REDIRECTS

        current_uri =
          if location.start_with?("http://", "https://")
            URI(location)
          else
            URI.join(current_uri, location)
          end
      end
    end
  end
end
