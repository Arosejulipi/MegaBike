# frozen_string_literal: true

# Create an admin user automatically in production when explicitly configured.
#
# Why: Render deploys often run migrations but not seeds, so the default admin
# from db/seeds.rb may not exist. This initializer is safe-guarded to avoid
# touching the DB before the schema exists and to avoid creating an admin unless
# a password is provided via env.
#
# Render env vars:
# - SEED_ADMIN_EMAIL (default: admin@megabike.com)
# - SEED_ADMIN_PASSWORD (required to enable)
# - SEED_ADMIN_NAME (optional)
begin
  next unless Rails.env.production?

  password = ENV["SEED_ADMIN_PASSWORD"].to_s
  next if password.strip.empty?

  email = (ENV["SEED_ADMIN_EMAIL"].presence || "admin@megabike.com").to_s.downcase.strip
  name = (ENV["SEED_ADMIN_NAME"].presence || "Admin Mega Bike").to_s

  next unless defined?(ActiveRecord::Base)
  next unless ActiveRecord::Base.connected?
  next unless ActiveRecord::Base.connection.data_source_exists?("users")

  user = User.find_by("lower(email) = ?", email)
  next if user.present?

  User.create!(
    email: email,
    name: name,
    password: password,
    password_confirmation: password,
    role: :admin
  )
rescue StandardError => e
  Rails.logger.error("seed_admin initializer failed: #{e.class}: #{e.message}") if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
end

