# frozen_string_literal: true

# Temporary middleware to capture any exception (even during boot/routing)
# and write it to public/last_error.log when EXPOSE_ERRORS_PUBLIC=1.
# Remove this file after debugging.

if ENV['EXPOSE_ERRORS_PUBLIC'] == '1'
  class PublicErrorLogger
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue Exception => e
      begin
        log_path = Rails.root.join('public', 'last_error.log')
        content = ["Exception: #{e.class}: #{e.message}", *e.backtrace].join("\n")
        File.write(log_path, content)
      rescue => write_err
        Rails.logger.error "PublicErrorLogger failed to write log: ", write_err
      end
      raise e
    end
  end

  Rails.application.config.middleware.insert_before(0, PublicErrorLogger)
end
