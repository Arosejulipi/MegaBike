# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = false

  config.consider_all_requests_local = true

  config.action_mailer.delivery_method = :test

  config.active_record.migration_error = :page_load
end
