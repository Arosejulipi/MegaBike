# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local = false

  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

 # config.active_storage.service = :local

  # SMTP por variables de entorno (ejemplo)
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   address: ENV.fetch("SMTP_ADDRESS"),
  #   port: ENV.fetch("SMTP_PORT", 587).to_i,
  #   user_name: ENV.fetch("SMTP_USER"),
  #   password: ENV.fetch("SMTP_PASSWORD"),
  #   authentication: :plain,
  #   enable_starttls_auto: true
  # }

  config.log_level = :info
  config.active_support.report_deprecations = false
end
