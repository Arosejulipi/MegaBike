# frozen_string_literal: true

class DebugController < ApplicationController
  # Only used when EXPOSE_ERRORS_PUBLIC=1
  def trigger
    # write a marker to verify the process can create the public file
    begin
      log_path = Rails.root.join('public', 'last_error.log')
      File.write(log_path, "Triggered at #{Time.current}\n")
    rescue => e
      Rails.logger.error "Failed writing trigger marker: #{e.class}: #{e.message}"
    end
    raise "Intentional debug exception (triggered by /__trigger_error)"
  end

  def status
    render json: {
      expose: ENV['EXPOSE_ERRORS_PUBLIC'] == '1',
      last_error_exists: File.exist?(Rails.root.join('public', 'last_error.log'))
    }
  end
end
