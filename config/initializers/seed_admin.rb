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
# - SEED_ADMIN_FORCE_RESET (optional; "1" to force password + role to match env)
begin
  if Rails.env.production?
    password = ENV["SEED_ADMIN_PASSWORD"].to_s.strip

    unless password.empty?
      email = (ENV["SEED_ADMIN_EMAIL"].presence || "admin@megabike.com").to_s.downcase.strip
      name = (ENV["SEED_ADMIN_NAME"].presence || "Admin Mega Bike").to_s
      force_reset = ENV["SEED_ADMIN_FORCE_RESET"].to_s.strip == "1"

      if defined?(ActiveRecord::Base)
        # Force a DB connection (ActiveRecord can be lazy during boot).
        conn = ActiveRecord::Base.connection

        # Avoid touching tables before migrations have run.
        if conn.data_source_exists?("users")
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
            # Ensure the configured user is actually admin.
            changed = false
            if !user.admin?
              user.role = :admin
              changed = true
            end

            if force_reset
              user.name = name if user.name.to_s.strip == ""
              user.password = password
              user.password_confirmation = password
              changed = true
            end

            user.save! if changed
          end
        end
      end
    end
  end
rescue StandardError => e
  Rails.logger.error("seed_admin initializer failed: #{e.class}: #{e.message}") if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
end
