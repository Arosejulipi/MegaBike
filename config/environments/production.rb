# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local = false

  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

# --- Action Mailer (SMTP Gmail) ---
config.action_mailer.perform_caching = false
config.action_mailer.delivery_method = :smtp
config.action_mailer.raise_delivery_errors = true
config.action_mailer.perform_deliveries = true

config.action_mailer.smtp_settings = {
  address: ENV.fetch("SMTP_ADDRESS", "smtp.gmail.com"),
  port: ENV.fetch("SMTP_PORT", "587").to_i,
  domain: ENV.fetch("SMTP_DOMAIN", "gmail.com"),
  user_name: ENV["SMTP_USERNAME"],
  password: ENV["SMTP_PASSWORD"],
  authentication: (ENV["SMTP_AUTHENTICATION"] || "plain").to_sym,
  enable_starttls_auto: (ENV.fetch("SMTP_ENABLE_STARTTLS_AUTO", "true") == "true")
}

# Para que en links de mails use tu dominio de Render
config.action_mailer.default_url_options = {
  host: ENV["APP_HOST"] || ENV.fetch("APP_HOST", "localhost"), # ejemplo: megabike.onrender.com
  protocol: ENV.fetch("APP_PROTOCOL", "https")
}

# Optional asset host for links to images/assets in mails
if ENV['APP_HOST'].present?
  config.action_mailer.asset_host = "#{ENV.fetch('APP_PROTOCOL', 'https')}://#{ENV['APP_HOST']}"
end

# Ensure ActiveJob has a working adapter in Render when Sidekiq/Redis aren't configured.
# :async runs jobs in background threads of the web process (ok for low-volume apps).
config.active_job.queue_adapter = (ENV.fetch('QUEUE_ADAPTER', 'async')).to_sym


  config.log_level = :info
  config.active_support.report_deprecations = false
end
