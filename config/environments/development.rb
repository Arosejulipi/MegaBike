# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true

  config.action_controller.perform_caching = false

  config.active_storage.service = :local

  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  config.action_mailer.delivery_method = :letter_opener_web
  config.action_mailer.perform_deliveries = true

  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load

  config.assets.debug = true
  config.assets.quiet = true
end
