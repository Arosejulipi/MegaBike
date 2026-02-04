# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local = false

  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Action Mailer: use Postmark (API) on Render. If not configured, disable deliveries.
  config.action_mailer.perform_caching = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true

  if ENV['POSTMARK_API_TOKEN'].present?
    config.action_mailer.delivery_method = :postmark
    config.action_mailer.postmark_settings = { api_token: ENV['POSTMARK_API_TOKEN'] }
  else
    # No mail provider configured: disable deliveries to avoid Net::OpenTimeout or other timeouts
    config.action_mailer.perform_deliveries = false
    Rails.logger.warn "ActionMailer: POSTMARK_API_TOKEN not set. Emails are disabled in production."
  end

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

# Active Storage service (use 'local' by default). To change, set ACTIVE_STORAGE_SERVICE env var.
config.active_storage.service = (ENV['ACTIVE_STORAGE_SERVICE'] || 'local').to_sym


  config.log_level = :info
  config.active_support.report_deprecations = false
end
