# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "active_storage/engine"
require "action_cable/engine"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module MegaBike
  class Application < Rails::Application
    config.load_defaults 7.1

    config.time_zone = "America/Argentina/Cordoba"
    config.i18n.default_locale = :es

    config.active_record.sqlite3_production_warning = false
  end
end
