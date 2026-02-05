# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local = false

  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  config.action_mailer.perform_caching = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true

  # Email provider selection (Render):
  # - If SMTP_ADDRESS is configured we use SMTP (works with Gmail/Outlook/etc).
  # - Otherwise, optional Postmark API.
  if ENV["SMTP_ADDRESS"].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: ENV.fetch("SMTP_ADDRESS"),
      port: (ENV["SMTP_PORT"].presence || 587).to_i,
      domain: ENV["SMTP_DOMAIN"].presence,
      user_name: ENV["SMTP_USERNAME"].presence,
      password: ENV["SMTP_PASSWORD"].presence,
      authentication: (ENV["SMTP_AUTHENTICATION"].presence || "plain"),
      enable_starttls_auto: (ENV.fetch("SMTP_ENABLE_STARTTLS_AUTO", "true") == "true")
    }.compact
  elsif ENV["POSTMARK_API_TOKEN"].present?
    config.action_mailer.delivery_method = :postmark
    config.action_mailer.postmark_settings = { api_token: ENV["POSTMARK_API_TOKEN"] }
  else
    # Avoid timeouts if no provider is configured.
    config.action_mailer.perform_deliveries = false
    Rails.logger.warn "ActionMailer: SMTP_ADDRESS/POSTMARK_API_TOKEN not set. Emails are disabled in production."
  end

  # For absolute links in emails
  config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST", "localhost"), # ejemplo: megabike.onrender.com
    protocol: ENV.fetch("APP_PROTOCOL", "https")
  }

  if ENV["APP_HOST"].present?
    config.action_mailer.asset_host = "#{ENV.fetch('APP_PROTOCOL', 'https')}://#{ENV['APP_HOST']}"
  end

  # Background jobs
  config.active_job.queue_adapter = ENV.fetch("QUEUE_ADAPTER", "async").to_sym

  # Active Storage service
  config.active_storage.service = (ENV["ACTIVE_STORAGE_SERVICE"] || "local").to_sym

  config.log_level = :info
  config.active_support.report_deprecations = false
end

