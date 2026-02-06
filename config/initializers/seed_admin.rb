# frozen_string_literal: true

# Ensure a deterministic admin user in production when SEED_ADMIN_PASSWORD is set.
#
# Render env vars:
# - SEED_ADMIN_EMAIL (default: admin@megabike.com)
# - SEED_ADMIN_PASSWORD (required)
# - SEED_ADMIN_NAME (optional)
#
# Why: Render deploys often run migrations but not seeds, so db/seeds.rb may not
# have been applied. We do this after initialization so the User model constant
# is loaded in production (where autoloading is off).

Rails.application.config.after_initialize do
  begin
    next unless Rails.env.production?

    password = ENV["SEED_ADMIN_PASSWORD"].to_s.strip
    next if password.empty?

    email = (ENV["SEED_ADMIN_EMAIL"].presence || "admin@megabike.com").to_s.downcase.strip
    name = (ENV["SEED_ADMIN_NAME"].presence || "Admin Mega Bike").to_s

    ActiveRecord::Base.connection_pool.with_connection do |conn|
      next unless conn.data_source_exists?("users")

      user = User.find_by("lower(email) = ?", email)

      if user.blank?
        User.create!(
          email: email,
          name: name,
          password: password,
          password_confirmation: password,
          role: :admin
        )
      else
        user.role = :admin unless user.admin?
        user.name = name if user.name.to_s.strip == ""
        user.password = password
        user.password_confirmation = password
        user.save!
      end
    end
  rescue StandardError => e
    Rails.logger.error("seed_admin after_initialize failed: #{e.class}: #{e.message}") if Rails.logger
  end
end

